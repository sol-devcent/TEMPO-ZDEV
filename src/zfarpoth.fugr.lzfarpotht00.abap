*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFARPOTH........................................*
DATA:  BEGIN OF STATUS_ZFARPOTH                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFARPOTH                      .
CONTROLS: TCTRL_ZFARPOTH
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFARPOTH                      .
TABLES: ZFARPOTH                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
