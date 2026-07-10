*&---------------------------------------------------------------------*
*& Program Name     : ZCOR_BUDGET_BALANCE                              *
*& Author           : Budi                                             *
*& Functional       : FAM                                              *
*& Create Date      : 24.08.2020                                       *
*& Program Type     : Report                                           *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Budget Balance Report                            *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zcor_budget_balance NO STANDARD PAGE HEADING
                           LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zcor_budget_balancetop.

INCLUDE zcor_budget_balancecl1.

*----------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.                    "lcl_handle_events DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_double_click.
    PERFORM show_cell_info USING 0 row column text-i05.
  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETER     : p_bukrs LIKE csks-bukrs OBLIGATORY DEFAULT '8010'
                                        MODIF ID pbu,
                p_gjahr LIKE bkpf-gjahr OBLIGATORY DEFAULT sy-datum(4)
                                        MODIF ID pgj,
                p_monat LIKE bkpf-monat OBLIGATORY DEFAULT sy-datum+4(2)
                                        MODIF ID pmo.
SELECT-OPTIONS: s_monat FOR bkpf-monat NO-EXTENSION NO-DISPLAY,
                s_gsber FOR csks-gsber MODIF ID csk,
                s_khinr FOR csks-khinr MODIF ID csk,
                s_kostl FOR csks-kostl MODIF ID csk,
                s_kstar FOR zcodt001-kstar MODIF ID sks.
PARAMETER p_new NO-DISPLAY DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK process WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP ra1 DEFAULT 'X'
                                        USER-COMMAND usr.
PARAMETERS radio2 RADIOBUTTON GROUP ra1.
SELECTION-SCREEN END OF BLOCK process.


*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_monat.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection-screen_output.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_khinr-low.
  PERFORM f_value_cc_group USING 'S_KHINR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_khinr-high.
  PERFORM f_value_cc_group USING 'S_KHINR-HIGH'.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.
  CASE 'X'.
    WHEN radio1.
      PERFORM f_get_data.
      PERFORM f_process_data.
      IF gt_out[] IS INITIAL.
        MESSAGE s000(zab) WITH 'Data not found' DISPLAY LIKE 'E'.
      ELSE.
        IF p_new IS INITIAL.
          PERFORM f_print_data.
        ELSE.
          PERFORM f_new_print_data.
        ENDIF.
      ENDIF.
    WHEN radio2.
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          action      = 'U'
          view_name   = 'ZCODT001'
        TABLES
          dba_sellist = selections
        EXCEPTIONS
          OTHERS      = 1.
  ENDCASE.
  PERFORM f_free_memory.

END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*

  INCLUDE zcor_budget_balancem01.

  INCLUDE zcor_budget_balancef01.

  INCLUDE zcor_budget_balancef02.

*------------------common includes for the program---------------------*
