*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFVATSHIPBTM....................................*
DATA:  BEGIN OF STATUS_ZFVATSHIPBTM                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFVATSHIPBTM                  .
CONTROLS: TCTRL_ZFVATSHIPBTM
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFVATSHIPBTM                  .
TABLES: ZFVATSHIPBTM                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
