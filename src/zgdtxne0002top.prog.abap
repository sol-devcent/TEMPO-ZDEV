*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE00002TOP                                           *
*----------------------------------------------------------------------*

TYPE-POOLS cxtab.
TABLES: zfvatnr.

*Control tables
CONTROLS: ctrl_1300 TYPE TABLEVIEW USING SCREEN 1300.
DATA:  wa_cols TYPE cxtab_column.

*Internal tables
DATA: BEGIN OF t_status OCCURS 0,
        tcode(5),
      END OF t_status.


*Selection screens
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:    p_vkorg LIKE vbrk-vkorg NO-DISPLAY,
                                " OBLIGATORY MEMORY ID vko,
               p_gsber LIKE vbrp-gsber NO-DISPLAY,
                                " OBLIGATORY MEMORY ID gsb,
               p_bukrs LIKE vbrk-bukrs NO-DISPLAY,
                                " OBLIGATORY MEMORY ID BUK,
               p_spart LIKE vbrk-spart NO-DISPLAY.
" OBLIGATORY MEMORY ID spa.
* Added by rama and above changed to no display
PARAMETERS:    p_brnch LIKE zgdtxdt0101-brnch
                                  OBLIGATORY MEMORY ID zbr,
               p_busln LIKE zgdtxdt0102-busln DEFAULT '01'
                                  OBLIGATORY MEMORY ID zbu.

PARAMETERS:    p_flag TYPE zgdtxde_fakgr OBLIGATORY DEFAULT '2'.
SELECTION-SCREEN END OF BLOCK b1.

* end of addition rama

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: s_fkdat FOR zgdtxdt0002-fkdat NO-EXTENSION
                        OBLIGATORY MEMORY ID fkd,
                s_stceg FOR vbrk-stceg NO INTERVALS MEMORY ID stc,
                s_vbeln FOR vbrk-vbeln MEMORY ID vf
                            MATCHCODE OBJECT vmcf.
PARAMETERS:     p_fakdat LIKE zgdtxdt0003-fakdat
***changed for Tempo
                         DEFAULT sy-datum
*                        OBLIGATORY.
                         NO-DISPLAY.
***end of change
PARAMETERS:     p_masatx LIKE zgdtxdt0002-masatx OBLIGATORY
                         MEMORY ID mtx.

PARAMETERS:     p_curr  LIKE vbrk-waerk
                        DEFAULT c_local_curr
*                        NO-DISPLAY
                        OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b2.

*** Added by Rahmadi -- Multiple pages
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
PARAMETERS:
****changed for Tempo -- remove option to avoid confusion
*            p_mpage RADIOBUTTON GROUP page DEFAULT 'X',
*            p_spage RADIOBUTTON GROUP page,
            p_mpage DEFAULT 'X' NO-DISPLAY,
            p_spage NO-DISPLAY,
            p_cust RADIOBUTTON GROUP form DEFAULT 'X',
            p_stan RADIOBUTTON GROUP form,
****end of Tempo changes
            p_dest LIKE tsp03-padest OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b3.
*** End of addition

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:      p_top NO-DISPLAY. "AS CHECKBOX .
*SELECTION-SCREEN COMMENT (50) text-999.
SELECTION-SCREEN END OF LINE.


*Hidden parameters to accomodate RPC program
*PARAMETERS    : p_rpc AS CHECKBOX.      "'X' if executed by RPC program
PARAMETERS    : p_rpc TYPE c NO-DISPLAY.
SELECT-OPTIONS: s_pstyv FOR vbrp-pstyv.  "Item categ. passed by RPC prog
***added for Tempo to accomodate external Nota Retur number
PARAMETERS    : p_noret LIKE zgdtxdt0002-noretur NO-DISPLAY.
***end of Tempo addition

*Screen 2000 to select item category for service billings
SELECTION-SCREEN BEGIN OF SCREEN 2000.
PARAMETERS: p_serv    RADIOBUTTON GROUP rdiv DEFAULT 'X',
            p_sparts  RADIOBUTTON GROUP rdiv,
            p_contra  RADIOBUTTON GROUP rdiv.
SELECTION-SCREEN END OF SCREEN 2000.
