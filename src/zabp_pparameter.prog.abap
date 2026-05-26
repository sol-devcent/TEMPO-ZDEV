*----------------------------------------------------------------------*
*   INCLUDE ZABP_PPARAMETER                                            *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE text-dat.
PARAMETERS: p_tdform    LIKE ssfscreen-fname DEFAULT 'ZGD*F*'
                        OBLIGATORY,
            p_dest      LIKE tsp03-padest DEFAULT 'BM1*',
            p_disp      LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK blxx.
