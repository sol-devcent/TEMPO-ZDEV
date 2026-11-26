*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFARPOTD2.......................................*
DATA:  BEGIN OF STATUS_ZFARPOTD2                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFARPOTD2                     .
CONTROLS: TCTRL_ZFARPOTD2
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFARPOTD2                     .
TABLES: ZFARPOTD2                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
