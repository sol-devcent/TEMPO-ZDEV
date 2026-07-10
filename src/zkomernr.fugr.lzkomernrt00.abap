*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 26.12.2006 at 15:50:14 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZKOMERNR........................................*
DATA:  BEGIN OF STATUS_ZKOMERNR                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZKOMERNR                      .
CONTROLS: TCTRL_ZKOMERNR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZKOMERNR                      .
TABLES: ZKOMERNR                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
