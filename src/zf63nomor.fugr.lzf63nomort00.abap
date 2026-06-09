*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63NOMOR.......................................*
DATA:  BEGIN OF STATUS_ZF63NOMOR                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63NOMOR                     .
CONTROLS: TCTRL_ZF63NOMOR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63NOMOR                     .
TABLES: ZF63NOMOR                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
