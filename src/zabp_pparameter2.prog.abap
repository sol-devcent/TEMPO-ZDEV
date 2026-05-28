*----------------------------------------------------------------------*
*   INCLUDE ZABP_PPARAMETER                                            *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE TEXT-dat.
PARAMETERS: p_tdform LIKE ssfscreen-fname DEFAULT 'ZGD*F*'
                        OBLIGATORY,
            p_dest   LIKE tsp03-padest DEFAULT 'BM1*'.

SELECTION-SCREEN SKIP.

PARAMETERS: p_disp   LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 3(50) TEXT-010.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blxx.
