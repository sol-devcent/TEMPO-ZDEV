*&---------------------------------------------------------------------*
*&  Include           ZS_CLOSING_PAKET_BACKGROUNDTOP
*&---------------------------------------------------------------------*

TABLES: tvkol,s705.

RANGES: r_mvgr2 FOR s706-mvgr2.

DATA: c_jobnameopp LIKE tbtcjob-jobname VALUE 'Closing OPP',
      c_jobnameppi LIKE tbtcjob-jobname VALUE 'Closing PPI'.

DATA: jobcount           LIKE tbtcjob-jobcount,
      host               LIKE msxxlist-host,
      starttimeimmediate LIKE btch0000-char1 VALUE 'X'.

DATA  BEGIN OF t_vkbur OCCURS 1.
DATA:   vkbur LIKE s700-vkbur.
DATA  END   OF t_vkbur.
