*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TRNHDR2.....................................*
DATA:  BEGIN OF STATUS_ZF63TRNHDR2                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TRNHDR2                   .
CONTROLS: TCTRL_ZF63TRNHDR2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TRNHDR2                   .
TABLES: ZF63TRNHDR2                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
