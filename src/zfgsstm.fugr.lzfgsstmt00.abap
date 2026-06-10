*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSSTM.........................................*
DATA:  BEGIN OF STATUS_ZFGSSTM                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSSTM                       .
CONTROLS: TCTRL_ZFGSSTM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFGSSTM                       .
TABLES: ZFGSSTM                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
