/* skkserv.c
 * SKK Server Version 3.9.5 of Dec 22, 1996
 * Copyright (C) 1994 Yukiyoshi Kameyama (kam@riec.tohoku.ac.jp)
 *
 * Programmed by
 * Yukiyoshi Kameyama (kam@riec.tohoku.ac.jp)
 * Research Institute of Electrical Communication
 * Tohoku University
 *
 * Contributed by 
 * Nobu Takahashi (nt@hpycla.yhp.co.jp) for System V patch
 * Chikahiro Kimura (kimura@2oa.kb.nec.co.jp) for "ntohs" bug
 * Koji Kawaguchi (guchi@pfu.fujitsu.co.jp) for various improvement
 * Hironobu Takahashi (takahasi@tiny.or.jp) for patch for char/int typing
 * Kazushi Marukawa (kazushi@kubota.co.jp) for cleaning up behavior in PRIVATE mode
 * TSUMURA Kazumasa (tsumura@fml.ec.tmit.ac.jp) for pointing out a bug in okuri-ari/nasi test
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either versions 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SKK, see the file COPYING.  If not, write to the Free
 * Software Foundation Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
/*
 * Description
 *	"skkserv" is a server daemon for an SKK/Nemacs client, which
 *	provides a facility of fast looking-up of an SKK-dictionary.
 *	skkserv and an SKK/Nemacs client can run on different hosts 
 *	which are connected by a TCP/IP network.
 *
 *	An old-style SKK-dictionary is a sorted sequence of lines in 
 *	the form: 
 *		YOMI /TANGO1/TANGO2/.../TANGOn/
 *	A new-style SKK-dictionary consists of two parts:
 *	The first part begins with the line
 *		;; okuri-ari entries.
 *	followed by the reverse-sorted sequence of lines in the same
 *	form as old-style.  In the first part, all the YOMI entries
 *	have "okurigana".
 *	The second part begins with the line
 *		;; okuri-nasi entries.
 *	followed by the sorted sequence of lines in the same form as
 *	old-style.  In the second part, all the YOMI entries do NOT
 *	have "okurigana".
 *	Other lines whose first two characters are ";;" will be ignored.
 *
 *	NOTE: the "sort" and "reverse-sort" should be emacs-sort, not
 *	UNIX sort (unsigned char, shorter is earlier).
 *
 *	Once invoked with a dictionary, the server runs permanently, 
 *	and waits for client's requests.
 *	A client, usually invoked by SKK/Nemacs, requests the server
 *	to transform a string (YOMI) to another string(/TANGO1/.../).
 *	Communication between the server and a client is done through
 *	a TCP-port "skkserv" by a UNIX socket.
 *	The server looks up the dictionary with the input string
 *	as the key, and replies its value to the client.
 *	If the input string is not found in the dictionary it replies
 *	'Not Found'.
 */

/*
 * Client Request Form
 *   "0"	end of connection
 *   "1eee "	eee is keyword in EUC code with ' ' at the end
 *   "2"	skkserv version number
 *   "3"	hostname and its IP addresses
 *
 * Server Reply Form for "1eee"
 *   "0"	Error
 *   "1eee"	eee is the associated line separated by '/'
 *   "4"	Not Found
 *
 * Server Reply Form for "2"
 *   "A.B "	A for major version number, B for minor version number 
 *		followed by a space
 *
 * Server Reply Form for "3"
 *   "string:addr1:...: "  string for hostname, addr1 for an IP address
 *	           	followed by a space
 */

#include	"skkserv.h"

#define CLIENT_END	'0'
#define CLIENT_REQUEST	'1'
#define CLIENT_VERSION	'2'
#define CLIENT_HOST	'3'

#define SERVER_ERROR	"0"
#define SERVER_FOUND	"1"
#define SERVER_NOT_FOUND "4"
#define SERVER_FULL	"9"

#define err(m)	\
	{if (debug) fprintf(errout, "%s: %s\n", pgmnm, m); exit(1);}

/*
 *	Global Variables
 */

char	pgmver[] = "3.9.4 ";	/* version number */

char	*pgmnm;		/* program name */
char	*jname;		/* name of shared dictionary */
char	hname[BUFSIZ];	/* hostname and IP address */
FILE	*jisho;		/* SKK jisho */
FILE	*errout;	/* Error Output */
int	debug;		/* flag for debugging */
int	portnum;	/* port number of TCP socket */

int	format;		/* 0 (old-style) / non-0 (new-style) */
int	jtab1[KANAMOJI]; /* index-table by 1st letter (1st part)*/
int	jtab2[KANAMOJI]; /* index-table by 1st letter (2nd part)*/
int	initsock;	/* socket for waiting requests */
int	clientsock[MAXCLNT];	/* socket for each client */
int	nclients;	/* max index for active clients */

main(argc, argv)
char *argv[];
{
  int	parg;
  int	setjisho = 0;
  int	ctlterm;	/* fildes for control terminal */
  void	reread();

  pgmnm = argv[0];
  debug = 0;
  errout = stderr;
  portnum = 0;

  /* The following patch (a work-around due to "rsh" bug) was pointed 	*/
  /* out by kazushi@kubota.co.jp in the message "714" in SKK-ML		*/
  /* Not knowing the reason in detail, I added it in any way, since	*/
  /* it does not have any bad effects even if not useful.		*/
  {	
    int i;
    for (i = 3; i < 15; i++)
      (void) close(i);
  }
    
  for (parg = 1; parg < argc; ) {
    if (*argv[parg] == '-') {
      switch (*(argv[parg]+1)) {
      case 'l':
      case 'L': 
	if (parg + 1 == argc) showusage();
	if ((errout = fopen(argv[++parg], "w")) == NULL) {
	  fprintf(stderr, "%s: opening logfile \"%s\" failed\n", 
		  pgmnm, *argv[parg]);
	  exit(1);
	}
	debug = 1; break;
      case 'd':
      case 'D': 
	debug = 1; break;
      case 'p':
      case 'P': 
	if (parg +1 == argc) showusage();
	portnum = atoi(argv[++parg]); break;
      default: showusage();
      }
    } else if (setjisho == 0) {
      jname = argv[parg];
      setjisho = 1;
    } else showusage();
    parg ++;
  }
  if (setjisho == 0)
    if ((jname = (char *) getenv("SKK_JISYO")) == NULL)
      jname = DEFAULT_JISYO;
  if ((jisho = fopen(jname, "r")) == NULL) {
    fprintf(stderr, 
	    "%s: opening shared dictionary \"%s\" failed\n", pgmnm, jname);
    exit(1);
  }

  set_hname();

  /* make socket */
  mksock();

  /* make table of contents for jisho */
  mkjtab();

  if (!debug) {
    /* parent process exits now */
    if (fork() != 0) exit(0);

    fclose(stdin);
    fclose(stdout);
    fclose(stderr);

    /* detach child process from control terminal */
#ifdef HAVE_TIOCNOTTY
    if ((ctlterm = open("/dev/tty", 2)) >= 0) { 
      ioctl(ctlterm, TIOCNOTTY, 0);
      close(ctlterm);
    }
    /*
     * I assume O_RDWR is 2. 
     * It is defined in <sys/fcntl.h> in 4.3 or <sys/file.h> in 4.2.
     * I don't want to care about the difference of names of header files
     */
#else
    setpgrp();
    signal(SIGHUP, SIG_IGN);
    if (fork() != 0) exit(0);
#endif
  } else { /* debug mode */
    fprintf(errout, "SKK-JISYO is %s\n", jname);
    fflush(errout);
    fclose(stdout);
    if (errout != stderr) fclose(stderr);
  }

  signal(SIGINT, reread);
  /* 1993/6/5 by kam, re-read dictionary by "INT" signal */

  nclients = 0;
  main_loop();
}

showusage()
{
  fprintf(stderr, 
	  "Usage: %s [-d] [-l logfile] [-p port] \n", pgmnm);
  fprintf(stderr, 
	  "       %s [-d] [-l logfile] [-p port] skk-jisho\n", pgmnm);
  exit(1);
}
 
/*
 *	make a socket
 */
mksock()
{
  struct sockaddr_in	sin;
  struct servent	*sp;
  int	optbuf = 1; /* enable socket REUSEADDR */
  
  bzero((char*)&sin, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = htonl(INADDR_ANY);
  if (portnum == 0) {
#ifdef PORTNUM
    portnum = PORTNUM;
#else
    if ((sp = getservbyname(SERVICE_NAME, "tcp")) == NULL)
      err("service name is undefined in /etc/services file");
    portnum = ntohs(sp->s_port);
#endif
  }
  sin.sin_port = htons(portnum); 

  if ((initsock = socket(PF_INET, SOCK_STREAM, 0)) < 0)
    err("socket error; socket cannot be created");
  if (setsockopt(initsock, SOL_SOCKET, SO_REUSEADDR, 
		 &optbuf, sizeof(optbuf)) < 0)
    err("socket error; cannot set socket option");
  if (bind(initsock, (struct sockaddr *)&sin, sizeof(sin))< 0) 
    err("bind error; the socket is already used");
  if (listen(initsock, MAXQUE) < 0) 
    err("listen error; something wrong happened with the socket");
  if (debug) {
    fprintf(errout, "file descriptor for initsock is %d\n", initsock);
    fflush(errout);
  }
}

/*
 *	make jisho table
 */
#define KANA_START	0xa4a1
#define KANA_END	0xa4f3
#define AFTER_KANA	(KANA_END - KANA_START + 1)
#define EOL		0x0a

#define	STR1		";; okuri-ari entries."
#define	STR2		" okuri-nasi entries."
#define	STRMARK		((';' << 8) | ';')

mkjtab()
{
  unsigned char	buf[BUFSIZE];

 again:
  if (fgets(buf, BUFSIZE, jisho) == NULL)
    err("no contents in jisho");
  if (format = (strncmp(buf, STR1, strlen(STR1)) == 0)) 
    mknewjtab();
  else if (buf[0] == ';' && buf[1] == ';')
    goto again;
  else 
    mkoldjtab(buf);
}

/* 1993/6/5 by kam, re-read dictionary by "INT" signal */
RETSIGTYPE reread()
{
  if (fclose(jisho) < 0) {
    fprintf(stderr, 
	    "%s: closing shared dictionary \"%s\" failed\n", pgmnm, jname);
    exit(1);
  }
  if ((jisho = fopen(jname, "r")) == NULL) {
    fprintf(stderr, 
	    "%s: rereading shared dictionary \"%s\" failed\n", pgmnm, jname);
    exit(1);
  }
  mkjtab();
}

mkoldjtab(s)
unsigned char	*s;
{
  register int	c;		/* one character */
  register int	*pjtab = &jtab2[0];
  register int	code;		/* compared code */
  register int	target;		/* target code (2 bytes) */

  code = KANA_START;

  target = (*s & 0xff) << 8;
  target |= *++s & 0xff;
  if (debug) {
    fprintf(stderr, "target is %c%c:%d:%d:%d:%d:%d\n", *(s-1), *s, target,
	    *(s-1), *s, target>>8, target&0xff);
    fprintf(stderr, "code is %c%c:%d\n", code >> 8, code & 0xff, code);
    fprintf(stderr, "target >= code is %d\n", target >= code);
  }
  while (target >= code && code <= KANA_END) {
    *pjtab++ = 0;
    code ++;
  }
    
  while ((c = fgetc(jisho)) != EOF) {
    target = ((c & 0xff)<< 8) | (fgetc(jisho) & 0xff);
    while (target >= code && code <= KANA_END) {
      *pjtab++ = ftell(jisho) - 2;
      code ++;
    }
    while ((c = fgetc(jisho)) != EOF) 
      if (c == EOL) break;
    if (code > KANA_END) {
      *pjtab++ = ftell(jisho);
      code ++;
      break;
    }
  }
  while (code <= KANA_END + 1) {
    *pjtab++ = ftell(jisho);
    code ++;
  }
  *pjtab = ftell(jisho); /* size of jisho */
  rewind(jisho);
  if (debug) {
    int	i;
    for (i = 0; i < AFTER_KANA + 1; i ++) {
      fprintf(stderr, "jtab %d = %d\n", i, jtab2[i]);
    }
  }
}


mknewjtab()
{
  register int	c;		/* one character */
  register int	*pjtab = &jtab1[0];
  register int	code;		/* compared code */
  register int	target;		/* target code (2 bytes) */
  unsigned char	buf[BUFSIZE];

  code = KANA_END;

  while ((c = fgetc(jisho)) != EOF) {
    target = ((c & 0xff)<< 8) | (fgetc(jisho) & 0xff);
    if (target == STRMARK) {
      fgets(buf, BUFSIZE, jisho);
      if (strncmp(buf, STR2, strlen(STR2)) == 0)
	break;
      else
	continue;
    }
    while (target <= code && code >= KANA_START) { 
      *pjtab++ = ftell(jisho) - 2;
      code --;
    }
    while ((c = fgetc(jisho)) != EOF) 
      if (c == EOL) break;
    if (code < KANA_START) {
      *pjtab++ = ftell(jisho);
      code ++;
      break;
    }
  }
  if (target != STRMARK)
    err("format error; new-style dictionary should have two parts");
  while (code >= KANA_START - 1) {
    *pjtab++ = ftell(jisho) - 2;
    code --;
  }
  *pjtab = ftell(jisho) - 2; /* size of jisho */
  if (debug) {
    int	i;
    for (i = 0; i < AFTER_KANA + 1; i ++) {
      fprintf(stderr, "jtab %d = %d\n", i, jtab1[i]);
    }
  }
  format = ftell(jisho);
  if (debug) fprintf(stderr, "format is %d\n", format);

  pjtab = &jtab2[0];
  code = KANA_START;
  while ((c = fgetc(jisho)) != EOF) {
    target = ((c & 0xff)<< 8) | (fgetc(jisho) & 0xff);
    while (target >= code && code <= KANA_END) { 
      *pjtab++ = ftell(jisho) - 2;
      code ++;
    }
    while ((c = fgetc(jisho)) != EOF) 
      if (c == EOL) break;
    if (code > KANA_END) {
      *pjtab++ = ftell(jisho);
      code ++;
      break;
    }
  }
  while (code <= KANA_END + 1) {
    *pjtab++ = ftell(jisho);
    code ++;
  }
  *pjtab = ftell(jisho); /* size of jisho */
  rewind(jisho);
  if (debug) {
    int	i;
    for (i = 0; i < AFTER_KANA + 1; i ++) {
      fprintf(stderr, "jtab %d = %d\n", i, jtab2[i]);
    }
  }
}

/*
 *	server main loop
 */

main_loop()
{
  fd_set 		readfds, writefds, exceptfds;
  fd_set 		getrfds();
  struct sockaddr_in	from;
  int			len;
  register int		i;

  FD_ZERO(&writefds);
  FD_ZERO(&exceptfds);
  for(;;) {	/* infinite loop; waiting for client's request */
    readfds = getrfds();
    if (select(MAXDTAB, &readfds, &writefds, &exceptfds, NULL) < 0) {
      if (errno == EINTR) /* if signal happens */
	continue;
      err("select error; something wrong happened with the socket");
    }
    if (debug) {
      fprintf(errout, "select: read file descriptor is %d\n", readfds);
      fflush(errout);
    }

    if (FD_ISSET(initsock, &readfds)) {
      len = sizeof(from);
      if ((clientsock[nclients ++] = accept(initsock, &from, &len)) < 0) {
	err("accept error; something wrong happened with the socket");
      }
      if (nclients >= MAXDTAB - 3 - debug * 2) {
	write(clientsock[--nclients], SERVER_FULL, 1);
	close(clientsock[nclients]);
      }
    }

    /*	naiive scheduling */
    for (i = 0; i < nclients; i ++)
      if (FD_ISSET(clientsock[i], &readfds)) {
	if (search(clientsock[i]) < 0) { 
	  		/* -1 means client closed the connection */
	  close(clientsock[i]);
	  clientsock[i] = clientsock[nclients - 1];
	  nclients --;
	}
      }

    if (debug) {
      fprintf(errout, "number of clients %d\n", nclients);
      fprintf(errout, "file descriptors of clients are :");
      for (i = 0; i < nclients; i ++) 
	fprintf(errout, "%d:", clientsock[i]);
      fputs("\n", errout);
      fflush(errout);
    }
  }
}

/*
 *	get bit pattern of read file descriptor
 */

fd_set getrfds()
{
  fd_set		rfds;
  register int		i;

  FD_ZERO(&rfds);
  FD_SET(initsock, &rfds);
  for (i = 0; i < nclients; i ++)
    FD_SET(clientsock[i], &rfds);
  return (rfds);
}

/*
 *	reply to client: linear search
 */

search(commsock)
int	commsock;
{	
  unsigned char	combuf[BUFSIZE]; /* comm. buffer between server & client */
  register unsigned char	*pbuf;
  register int	code; 		 /* first two bytes */
  register int	c; 		 /* one character */
  int		n; 	 	 /* number of characters from client */
  int		sttpnt; 	 /* start point of searching */
  int		endpnt; 	 /* end point of searching */
  int		errcod = 0; 	 /* error flag */
  int		sstyle;		 /* search style */

/* fix 1990/6/26  
 * if a client dies, it may send 0-byte through the socket 
 */

  if ((n = read(commsock, &combuf[0], BUFSIZE)) <= 0) {
    if (debug) {
      fprintf(errout, "read error; transmission between processes\n");
      fflush(errout);
    }
    return(-1);
  }

  if (combuf[0] == CLIENT_END) {
    if (debug) {
      fprintf(errout, "message from client:END\n");
      fflush(errout);
    }
    return(-1);
  } else if (combuf[0] == CLIENT_VERSION) {
    if (debug) {
      fprintf(errout, "message from client:VERSION\n");
      fflush(errout);
    }
    if (write(commsock, pgmver, strlen(pgmver)) < 0) {
      if (debug) {
	fprintf(errout, "error in writing to socket\n");
	fflush(errout);
      }
      return(-1);
    }
    return(0);
  } else if (combuf[0] == CLIENT_HOST) {
    if (debug) {
      fprintf(errout, "message from client:HOST\n");
      fflush(errout);
    }
    if (write(commsock, hname, strlen(hname)) < 0) {
      if (debug) {
	fprintf(errout, "error in writing to socket\n");
	fflush(errout);
      }
      return(-1);
    }
    return(0);
  } else if (combuf[0] != CLIENT_REQUEST) {
    if (debug) {
      fprintf(errout, "message from client:UNKNOWN[%d]\n", combuf[0]);
      fflush(errout);
    }
    return(0);
  }
  
  if (debug) {
    fputs("message from client:WORD:", errout);
    for (pbuf = &combuf[1]; *pbuf != ' '; pbuf ++)
      fputc(*pbuf, errout);
    fputs(":\n\n", errout);
    fflush(errout);
  }

  if (format == 0) 
    sstyle = 0;
  else {
    sstyle = 2;
    pbuf = &combuf[1];
    if ((*pbuf & 0x80) != 0) {
      while (*pbuf != ' ')
	pbuf ++;
#ifdef oldbug
      if ((*(pbuf-1) & 0x80) == 0)
	sstyle = 1;
#else
      if ((*(pbuf-1) >= 'a') && (*(pbuf-1) <= 'z'))
	sstyle = 1;
#endif
    }
  }

  code = ((combuf[1] & 0xff) << 8) | (combuf[2] & 0xff);
  if ((sstyle == 0) || (sstyle == 2)) {
    if (code < KANA_START) {
      if (sstyle == 0)
	sttpnt = 0;
      else 
	sttpnt = format;
      endpnt = jtab2[0];
    } else if (code > KANA_END) {
      sttpnt = jtab2[AFTER_KANA];
      endpnt = jtab2[AFTER_KANA + 1];
    } else {
      sttpnt = jtab2[code - KANA_START];
      endpnt = jtab2[code - KANA_START + 1];
    } 
  } else {
    if (code < KANA_START) {
      sttpnt = jtab1[AFTER_KANA];
      endpnt = jtab1[AFTER_KANA + 1];
    } else if (code > KANA_END) {
      sttpnt = 0;
      endpnt = jtab1[0];
    } else {
      sttpnt = jtab1[KANA_END - code];
      endpnt = jtab1[KANA_END - code + 1];
    }
  }
  fseek(jisho, sttpnt, 0);
  if (debug)
    fprintf(stderr, "from %d to %d\n", sttpnt, endpnt);
  
  while ((c = fgetc(jisho)) != EOF) {
    pbuf = &combuf[1]; /* ' ' is end-symbol */
    while (c == *pbuf && c != ' ' && c != EOL) {
      if (debug) {fprintf(errout, "1:%d:%d:%d:%d:\n", c, *pbuf, ' ', EOL);}
      c = fgetc(jisho); pbuf++;
    } 
    if (debug) {fprintf(errout, "1:%d:%d:%d:%d:\n", c, *pbuf, ' ', EOL);}
    if (c == ' ' && (*pbuf == ' ' || *pbuf == '\n')) { /* found */
      if ((errcod = write(commsock, SERVER_FOUND, 1)) >= 0)
	while ((c = fgetc(jisho)) != EOF) {
	  *pbuf = c;
	  if ((errcod = write(commsock, pbuf, 1)) < 0) break;
	  else if (c == EOL) break;
	}
      if (errcod < 0) {
	if (debug) {
	  fprintf(errout, "error in writing to socket\n");
	  fflush(errout);
	}
	return(-1);
      }
      return(0);
    }
    if (comp(*pbuf, c, sstyle)) {
      if (debug) {
	fprintf(stderr, "comp break %d \n", ftell(jisho));
      }
      break; 
    }
                       /* fix 1992/3/6 under suggestion  */
		       /* of guchi@pfu.fujitsu.co.jp     */
    while ((c = fgetc(jisho)) != EOF) {
      if (c == EOL) break;
    }
    if (ftell(jisho) >= endpnt) break;
  }

  if ((errcod = write(commsock, SERVER_NOT_FOUND, 1)) >= 0) {
    combuf[n] = '\0';
    errcod = write(commsock, &combuf[1], strlen(&combuf[1]));
  }
  if (errcod < 0) {
    if (debug) {
      fprintf(errout, "error in writing to socket\n");
      fflush(errout);
    }
    return(-1);
  }
  return(0);
}

comp(c1, c2, f)
int c1, c2, f;
{
  if (debug) {
    fprintf(stderr, "c1 %d c2 %d f %d\n", c1, c2, f);
  }
  if ((c1 == ' ') || (c1 == '\n')) c1 = 0; /* shorter is earlier */
  if (c2 == ' ') c2 = 0;
  if (f != 1)
    return (c1 < c2);
  else
    return (c1 > c2);
}

set_hname()
{
  struct hostent	*hentry;
  char	**p;

  if (gethostname(hname, BUFSIZE) < 0) {
    fprintf(errout, "%s:cannot get hostname, or too long hostname\n", pgmnm);
    exit(1);
  }
  hentry = gethostbyname(hname);
#ifdef NO_ADDR_LIST
  strcat(hname, ":");
  strcat(hname, hentry->h_addr);
#else
  p = hentry->h_addr_list;
  while (*p != NULL) {
    strcat(hname, ":");
    /* Patch by SAITO Tetsuya on Nov 9, 1996 */
    /* strcat(hname, *p++); */
    strcat(hname, inet_ntoa(*(struct in_addr *)*p++));
  }
#endif
  strcat(hname, ": ");
}

