*----------------------------------------------------------------------*
*   INCLUDE Z_PPARAMETER                                               *
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE text-dat.
PARAMETERS: p_tdform    LIKE ssfscreen-fname NO-DISPLAY,
            p_dest      LIKE tsp03-padest DEFAULT sy-pdest,
            p_disp      LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK blxx.
