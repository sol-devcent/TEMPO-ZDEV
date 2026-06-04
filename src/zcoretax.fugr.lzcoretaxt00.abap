*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCORETAX0001....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0001                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0001                  .
CONTROLS: TCTRL_ZCORETAX0001
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZCORETAX0002....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0002                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0002                  .
CONTROLS: TCTRL_ZCORETAX0002
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZCORETAX0005....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0005                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0005                  .
CONTROLS: TCTRL_ZCORETAX0005
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: ZCORETAX0006....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0006                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0006                  .
CONTROLS: TCTRL_ZCORETAX0006
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZCORETAX0007....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0007                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0007                  .
CONTROLS: TCTRL_ZCORETAX0007
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: ZCORETAX0008....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0008                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0008                  .
CONTROLS: TCTRL_ZCORETAX0008
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: ZCORETAX0009....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0009                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0009                  .
CONTROLS: TCTRL_ZCORETAX0009
            TYPE TABLEVIEW USING SCREEN '0008'.
*...processing: ZCORETAX0010....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0010                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0010                  .
CONTROLS: TCTRL_ZCORETAX0010
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: ZCORETAX0012....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0012                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0012                  .
CONTROLS: TCTRL_ZCORETAX0012
            TYPE TABLEVIEW USING SCREEN '0009'.
*.........table declarations:.................................*
TABLES: *ZCORETAX0001                  .
TABLES: *ZCORETAX0002                  .
TABLES: *ZCORETAX0005                  .
TABLES: *ZCORETAX0006                  .
TABLES: *ZCORETAX0007                  .
TABLES: *ZCORETAX0008                  .
TABLES: *ZCORETAX0009                  .
TABLES: *ZCORETAX0010                  .
TABLES: *ZCORETAX0012                  .
TABLES: ZCORETAX0001                   .
TABLES: ZCORETAX0002                   .
TABLES: ZCORETAX0005                   .
TABLES: ZCORETAX0006                   .
TABLES: ZCORETAX0007                   .
TABLES: ZCORETAX0008                   .
TABLES: ZCORETAX0009                   .
TABLES: ZCORETAX0010                   .
TABLES: ZCORETAX0012                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
