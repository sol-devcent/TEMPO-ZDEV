*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDGFIDT005V.....................................*
TABLES: ZDGFIDT005V, *ZDGFIDT005V. "view work areas
CONTROLS: TCTRL_ZDGFIDT005V
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_ZDGFIDT005V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZDGFIDT005V.
* Table for entries selected to show on screen
DATA: BEGIN OF ZDGFIDT005V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZDGFIDT005V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZDGFIDT005V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZDGFIDT005V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZDGFIDT005V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZDGFIDT005V_TOTAL.

*.........table declarations:.................................*
TABLES: SKA1                           .
TABLES: SKAT                           .
TABLES: ZDGFIDT005                     .
