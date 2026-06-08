*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TYTPEEXPDESC................................*
DATA:  BEGIN OF STATUS_ZF63TYTPEEXPDESC              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TYTPEEXPDESC              .
CONTROLS: TCTRL_ZF63TYTPEEXPDESC
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TYTPEEXPDESC              .
TABLES: ZF63TYTPEEXPDESC               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
