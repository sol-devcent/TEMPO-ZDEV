*&----------------------------------------------------------------------------*
*& D R A G O N   G L O R Y   P R O J E C T
*&----------------------------------------------------------------------------*
*& RICEF ID              : RCO-09
*& Functional Designer   : Amirullah Amaludin (IBM)
*& ABAP Developer        : Budi
*& Initial Creation Date : 15.06.2022
*&
*& Laporan monitoring budget terhadap RFA commitment dan actual value pembelian
*& asset atau untuk capital expense lainnya
*& ( Copy form ZDG2CO_R005 )
*&
*&
*& Logical DB : N/A
*&
*& Assumption : N/A
*&
*&----------------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&----------------------------------------------------------------------------*
*& Date        By        TR#          Version  Description
*&----------------------------------------------------------------------------*
*& 01.05.2012  Budi.P  DEVK931591     01       Initial creation
*&
*&----------------------------------------------------------------------------*
REPORT zdg2co_r005n NO STANDARD PAGE HEADING
                    LINE-SIZE 623.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* Upload and download flat file macors
INCLUDE zabp_udf.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zdg2co_r005ntop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK value WITH FRAME TITLE text-001.
PARAMETERS: p_kokrs LIKE aufk-kokrs OBLIGATORY,
            p_bukrs LIKE aufk-bukrs OBLIGATORY.
SELECTION-SCREEN END OF BLOCK value.

SELECTION-SCREEN BEGIN OF BLOCK group WITH FRAME TITLE text-002.
PARAMETERS: p_setnm LIKE setnode-setname.
SELECT-OPTIONS: s_aufnr FOR aufk-aufnr,
                s_akstl FOR aufk-akstl.
PARAMETERS: p_gjahr LIKE bpja-gjahr OBLIGATORY.

SELECTION-SCREEN SKIP.

PARAMETERS: p_rad1 RADIOBUTTON GROUP grp1 USER-COMMAND us1,
            p_rad2 RADIOBUTTON GROUP grp1.

SELECTION-SCREEN SKIP.
PARAMETERS: p_alv AS CHECKBOX MODIF ID hid.
SELECTION-SCREEN END OF BLOCK group.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'HID'. "AND sy-sysid NE 'DEV'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_collect_order_number.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_summary_total.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*----------------------------------------------------------------------*
* TOP-OF-PAGE.
*----------------------------------------------------------------------*
TOP-OF-PAGE.
  IF sy-dynnr = '0555' OR p_rad2 = 'X'.
    NEW-PAGE LINE-SIZE 318.
    PERFORM f_top_of_page.
    PERFORM f_header_popup.
  ELSE.
    NEW-PAGE LINE-SIZE 623.
    PERFORM f_top_of_page.
    PERFORM f_sub_header.
  ENDIF.

*----------------------------------------------------------------------*
* USER-COMMAND
*----------------------------------------------------------------------*
AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN '&DOWN'.
      PERFORM f_download_csv.
    WHEN '&IC1'.
      GET CURSOR FIELD fname VALUE fvalue.
      CASE fname.
        WHEN 'T_OUT-AUFNR'.
          PERFORM f_line_selection USING fvalue.
        WHEN OTHERS.
      ENDCASE.
  ENDCASE.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zdg2co_r005nf01.

*------------------common includes for the program---------------------*
