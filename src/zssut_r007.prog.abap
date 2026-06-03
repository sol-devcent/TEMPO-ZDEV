*&---------------------------------------------------------------------*
*& Program Name     : ZSSUT_R007                                       *
*& Module Name      : SD                                               *
*& Author           : Aji (SAP_DEV02)                                  *
*& Functional       : Gunawan                                          *
*& Create Date      : 01/11/2013                                       *
*& Program Type     : Dialog                                           *
*& Transaction      : N/A                                               *
*& SAP Release      : ECC6                                             *
*& Description      : All-In-One Daily Call Plan Screen Process
*&---------------------------------------------------------------------*
*& REVISION LOG                                                        *
*&---------------------------------------------------------------------*
*& 1   DEVK936589   Aji  22/10/2013   Initial Creation                 *
*&                                                                     *
*&---------------------------------------------------------------------*


REPORT  zssut_r007.
tables: ZSCUST_CONTROL.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(20) text-002.
SELECTION-SCREEN END OF LINE.

PARAMETERS: r03 RADIOBUTTON GROUP r1 DEFAULT 'X'.


SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: r09 RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 3(20) text-004.
PARAMETERS: c01 AS CHECKBOX.
SELECTION-SCREEN COMMENT 26(10) text-005.

SELECTION-SCREEN END OF LINE.
PARAMETERS: r04 RADIOBUTTON GROUP r1,
            r07 RADIOBUTTON GROUP r1,
            r08 RADIOBUTTON GROUP r1,
            r10 RADIOBUTTON GROUP r1,
            r11 RADIOBUTTON GROUP r1,
            r12 RADIOBUTTON GROUP r1.


SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(23) text-003.
SELECTION-SCREEN END OF LINE.

PARAMETERS: r01 RADIOBUTTON GROUP r1,
            r02 RADIOBUTTON GROUP r1,
            r05 RADIOBUTTON GROUP r1,
            r06 RADIOBUTTON GROUP r1.

SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.



START-OF-SELECTION.
  CASE 'X'.
    WHEN r01.
      CALL TRANSACTION 'ZSSUT001'.
    WHEN r02.
      CALL TRANSACTION 'ZSSUT002'.
    WHEN r03.
      CALL TRANSACTION 'ZSSUT007'.
*      SUBMIT zssut_r002 VIA SELECTION-SCREEN AND RETURN.
    WHEN r04.
      CALL TRANSACTION 'ZSSUT008'.
*      SUBMIT zssut_r005 VIA SELECTION-SCREEN AND RETURN.
    WHEN r05.
*      CALL TRANSACTION 'ZSSUT009'.
      CALL TRANSACTION 'ZSSUT011'.
*      SUBMIT zssut_r004 VIA SELECTION-SCREEN AND RETURN.
    WHEN r06.
      CALL TRANSACTION 'ZSSUT003'.
    WHEN r07.
*      CALL TRANSACTION 'ZSSUT010'.
      SUBMIT zssut_r006 VIA SELECTION-SCREEN AND RETURN.
    WHEN r08.
      CALL TRANSACTION 'ZSSUT005'.
    WHEN r09.
      IF c01 = 'X'.
        CALL TRANSACTION 'ZSFASDI001'.
      ELSE.
        CALL TRANSACTION 'ZSSUT006'.
      ENDIF.
    WHEN r10.
      SUBMIT zssut_r012 VIA SELECTION-SCREEN AND RETURN.
    WHEN r11.
      CALL TRANSACTION 'ZSSUT012'.
    WHEN r12.
      SUBMIT ZSFASD_I0026 VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.
