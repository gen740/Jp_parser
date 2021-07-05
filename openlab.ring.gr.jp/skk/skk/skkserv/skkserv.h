/* skkserv.h
 * SKK Server Version 3.9.3 of Jun 17, 1994
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
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either versions 2, or (at your option)
 * any later version.

 * This program is distributed in the hope that it will be useful
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with SKK, see the file COPYING.  If not, write to the Free
 * Software Foundation Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "config.h"

/* if your hostent structure defined in "netdb.h" does not have */
/* h_addr_list, uncomment the following line */
/* #define NO_ADDR_LIST */
/* Necessary for SunOS 3.x and maybe other old systems */

#include	<stdio.h>

#include	<sys/types.h>
#ifdef HAVE_SYS_IOCTL_H
#include	<sys/ioctl.h>
#endif
#include	<sys/socket.h>
#include	<netinet/in.h>
#include	<netdb.h>
#include	<signal.h>
#include	<errno.h>

#ifndef DEFAULT_JISYO
#define DEFAULT_JISYO 	"/usr/local/share/emacs/SKK-JISYO.L"	
#endif
					/* default jisho name */
#define SERVICE_NAME	"skkserv"	/* service name */

#ifdef PRIVATE
#define PORTNUM	1178
#endif

#define	MAXQUE		5
#ifdef HAVE_GETDTABLESIZE
#define MAXDTAB		getdtablesize()	
				/* max number of file descriptors */
				/* it returns 64 on SunOS 4.x & NEWS OS 3.3 */
				/* it returns 30 on SunOS 3.x & NEWS OS 2.2 */
				/* 20 is guaranteed on all machines */
#else
#define MAXDTAB		_NFILE
#endif
#define MAXCLNT		64	/* max number of clients */
                                /* (must be larger than MAXDTAB-1) */
#define	BUFSIZE		512	/* max size of a request */
#define KANAMOJI	100	/* number of KANA moji */

#ifndef HAVE_BZERO
#define bzero(b, l) memset((b), 0, (l))
#endif

/*
 * bit-operation in select
 */
#ifndef FD_SET
#define	NFDBITS	(sizeof(long) * 8)
#define	FD_SET(n, p)	((p)->fds_bits[(n)/NFDBITS] |= (1 << ((n) % NFDBITS)))
#define	FD_CLR(n, p)	((p)->fds_bits[(n)/NFDBITS] &= ~(1 << ((n) % NFDBITS)))
#define	FD_ISSET(n, p)	((p)->fds_bits[(n)/NFDBITS] & (1 << ((n) % NFDBITS)))
#define	FD_ZERO(p)	bzero((char *)(p), sizeof(*(p)))
#endif
