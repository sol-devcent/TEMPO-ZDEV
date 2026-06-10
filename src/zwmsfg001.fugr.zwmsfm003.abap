FUNCTION zwmsfm003.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROCESS) TYPE  CHAR30
*"     VALUE(PI_DATA) TYPE  STRING
*"     REFERENCE(PI_LGNUM) TYPE  LTAK-LGNUM OPTIONAL
*"     REFERENCE(PI_TANUM) TYPE  CHAR20 OPTIONAL
*"  EXPORTING
*"     REFERENCE(PALLET_NUMBER) TYPE  CHAR10
*"     REFERENCE(TRANSFER_ORDER_NUMBER) TYPE  CHAR10
*"     REFERENCE(PI_TYPE) TYPE  CHAR1
*"     REFERENCE(PI_MESSAGE) TYPE  BAPI_MSG
*"     REFERENCE(PE_CHECK) TYPE  ZWMSST007
*"  TABLES
*"      PT_TO STRUCTURE  ZWMSST001 OPTIONAL
*"      PT_PICK STRUCTURE  ZWMSST002 OPTIONAL
*"      PT_PICKCMPL STRUCTURE  ZWMSST003 OPTIONAL
*"      PT_PICKAKHIR STRUCTURE  ZWMSST004 OPTIONAL
*"      PT_PICKA STRUCTURE  ZWMSST005 OPTIONAL
*"      PT_CHECK STRUCTURE  ZWMSST006 OPTIONAL
*"      PT_LOAD STRUCTURE  ZWMSST008 OPTIONAL
*"      PT_LOADP STRUCTURE  ZWMSST009 OPTIONAL
*"      PT_DCC STRUCTURE  ZWMSST010 OPTIONAL
*"      PT_PID STRUCTURE  ZWMSST011 OPTIONAL
*"      PT_SIR STRUCTURE  ZWMSST012 OPTIONAL
*"----------------------------------------------------------------------
  DATA : lv_pallet_number(10).

  IF pi_data IS NOT INITIAL.
    CASE pi_process.
      WHEN 'CREATE_TO'.
*        PERFORM f_proses_create_to TABLES pt_to
*                                   USING pi_data
*                                   CHANGING transfer_order_number lv_pallet_number
*                                            pi_type pi_message.

        PERFORM f_proses_create_to_new TABLES pt_to
                                       USING pi_data
                                       CHANGING transfer_order_number lv_pallet_number
                                                pi_type pi_message.

      WHEN 'COMPLETE_SHIPMENT'.
        PERFORM f_proses_complete_shipment USING pi_data
                                           CHANGING pi_type pi_message.

      WHEN 'LOADING_RELEASE'.
        PERFORM f_proses_loading_release TABLES pt_load
                                         USING pi_data
                                         CHANGING pi_type pi_message.

      WHEN 'LOADING_PROCESS'.
        PERFORM f_proses_loading_process TABLES pt_loadp
                                         USING pi_data.

      WHEN 'PICKING_CONFIRM'.
        PERFORM f_proses_picking TABLES pt_pick
                                 USING pi_data
                                 CHANGING pi_type pi_message.

      WHEN 'PICKING_CONF_AKHIR'.
        PERFORM f_proses_pickconf_akhir TABLES pt_picka
                                        USING pi_data
                                        CHANGING pi_type pi_message.

      WHEN 'CHECKER_CONFIRM'.
        PERFORM f_proses_checker_confirm TABLES pt_check
                                         USING pi_data.

      WHEN 'PICKING_COMPLETE'.
        PERFORM f_proses_picking_complete TABLES pt_pickcmpl
                                          USING pi_data
                                          CHANGING pi_type pi_message.

      WHEN 'PICKING_CMPL_AKHIR'.
        PERFORM f_proses_pickcmpl_akhir TABLES pt_pickcmpl
                                        USING pi_data
                                        CHANGING pi_type pi_message.
      WHEN 'CHECKER_COMPLETE'.
        PERFORM f_proses_checker_complete USING pi_data
                                          CHANGING pe_check.

      WHEN 'CREATE_TO_PO'.
        PERFORM f_proses_create_to_po TABLES pt_to
                                   USING pi_data
                                   CHANGING transfer_order_number lv_pallet_number
                                            pi_type pi_message.
        pallet_number = lv_pallet_number.

      WHEN 'POST_DCC'.
        PERFORM f_proses_post_dcc TABLES pt_dcc
                                  USING pi_data
                                  CHANGING lv_pallet_number pi_type pi_message.
        pallet_number = lv_pallet_number.

      WHEN 'POST_PID'.
        PERFORM f_proses_post_pid TABLES pt_pid
                                  USING pi_data.

      WHEN 'POST_SIR'.
        PERFORM f_proses_post_sir TABLES   pt_sir
                                  USING    pi_data
                                  CHANGING pallet_number pi_type pi_message.

      WHEN OTHERS.
    ENDCASE.
  ELSE.
    CASE pi_process.
      WHEN 'GET_PICKING_AKHIR'.
        PERFORM f_get_picking_akhir TABLES pt_pickakhir
                                    USING pi_lgnum pi_tanum
                                    CHANGING pi_type pi_message.

    ENDCASE.
  ENDIF.
ENDFUNCTION.
