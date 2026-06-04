*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHSMMMDT008.....................................*
DATA:  BEGIN OF STATUS_ZHSMMMDT008                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHSMMMDT008                   .
CONTROLS: TCTRL_ZHSMMMDT008
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHSMMMDT008                   .
TABLES: ZHSMMMDT008                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
