*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFAREA..........................................*
DATA:  BEGIN OF STATUS_ZFAREA                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFAREA                        .
CONTROLS: TCTRL_ZFAREA
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFAREA                        .
TABLES: ZFAREA                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
