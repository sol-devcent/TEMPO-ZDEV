*&----------------------------------------------------------------------
*&
*&----------------------------------------------------------------------
*& RICEF ID             : IACC-01
*& Program Name         : ZACCMM_I001
*& Functional Designer  : Guritno
*& ABAP Developer       : Budi P.
*& Creation Date        : 05.01.2021
*& SAP Release          : ECC6.0
*& Description          : Interface Upload SN
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001
*&
*&---------------------------------------------------------------------*
REPORT  zaccmm_i001 NO STANDARD PAGE HEADING
                     LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zsfa_interface_incl.
INCLUDE zaccmm_i001top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: p_path  TYPE char128 OBLIGATORY LOWER CASE
                    DEFAULT '/interface/' MODIF ID pat.
PARAMETERS: p_start(15) DEFAULT 'CSN'.
SELECTION-SCREEN END OF BLOCK block1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_path.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'P_PATH'.
      screen-input = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  PERFORM f_init_path.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM f_init_path.

  v_file_prefix = c_starttext.

  CONCATENATE p_path 'in/'    INTO v_interfacein.
  CONCATENATE p_path 'done/'  INTO v_interfacedone.
  CONCATENATE p_path 'error/' INTO v_interfaceerror.

  IF p_start NE space.
    v_file_prefix = p_start.
  ENDIF.

  PERFORM f_get_file_name USING v_interfacein
                                all_gen          "just give all_gen as value for this parameter
                                v_file_prefix.

  SORT i_file_list BY name ASCENDING.
  fileindex = 0.

  LOOP AT i_file_list.
*    perform initialize_all.            "initialize all variables ...
    CLEAR: wa_itabline, itabline,gt_zaccmmdt001,gv_error,gv_msg,gt_itab_c,gv_flag.
    REFRESH: itabline,gt_zaccmmdt001,gt_itab_c.

    PERFORM f_read_file USING i_file_list-dirname
                              i_file_list-name.

    CLEAR:  wa_itabline.

    WRITE: / sy-uline.

    PERFORM f_proses_data.

    IF gv_error IS INITIAL.
      "move files using read-write operation ...
      PERFORM f_move_file USING i_file_list-name
                                i_file_list-name
                                i_file_list-dirname
                                v_interfacedone.
    ELSE.
      "move files using read-write operation ...
      PERFORM f_move_file USING i_file_list-name
                                i_file_list-name
                                i_file_list-dirname
                                v_interfaceerror.
    ENDIF.

    MODIFY i_file_list.
  ENDLOOP.

  WRITE: / sy-uline.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
  INCLUDE zaccmm_i001f01.
