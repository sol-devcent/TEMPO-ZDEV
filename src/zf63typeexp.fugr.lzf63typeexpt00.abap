*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TYPEEXP.....................................*
DATA:  BEGIN OF STATUS_ZF63TYPEEXP                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TYPEEXP                   .
CONTROLS: TCTRL_ZF63TYPEEXP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TYPEEXP                   .
TABLES: ZF63TYPEEXP                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
