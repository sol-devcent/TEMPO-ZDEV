*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT003........................................*
DATA:  BEGIN OF STATUS_ZFIDT003                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT003                      .
CONTROLS: TCTRL_ZFIDT003
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT003                      .
TABLES: ZFIDT003                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
