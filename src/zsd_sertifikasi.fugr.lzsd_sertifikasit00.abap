*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSD_SERTIFIKASI.................................*
DATA:  BEGIN OF STATUS_ZSD_SERTIFIKASI               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSD_SERTIFIKASI               .
CONTROLS: TCTRL_ZSD_SERTIFIKASI
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSD_SERTIFIKASI               .
TABLES: ZSD_SERTIFIKASI                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
