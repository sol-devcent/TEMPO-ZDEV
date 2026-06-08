*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 05.03.2007 at 11:55:56 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZFNREXCLUDE.....................................*
DATA:  BEGIN OF STATUS_ZFNREXCLUDE                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNREXCLUDE                   .
CONTROLS: TCTRL_ZFNREXCLUDE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFNREXCLUDE                   .
TABLES: ZFNREXCLUDE                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
