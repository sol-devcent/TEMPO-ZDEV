*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TRNVCH......................................*
DATA:  BEGIN OF STATUS_ZF63TRNVCH                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TRNVCH                    .
CONTROLS: TCTRL_ZF63TRNVCH
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TRNVCH                    .
TABLES: ZF63TRNVCH                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
