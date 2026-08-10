*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDPPDT0014.....................................*
DATA:  BEGIN OF STATUS_ZGDPPDT0014                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDPPDT0014                   .
CONTROLS: TCTRL_ZGDPPDT0014
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZGDPPDT0014                   .
TABLES: ZGDPPDT0014                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
