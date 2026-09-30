FUNCTION zhgwmfm001 .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PI_PROCESS) TYPE  CHAR30 OPTIONAL
*"     REFERENCE(PI_DATA) TYPE  STRING OPTIONAL
*"     REFERENCE(PI_LGNUM) TYPE  LRF_WKQU-LGNUM OPTIONAL
*"     REFERENCE(PI_TANUM) TYPE  LTAK-TANUM OPTIONAL
*"     REFERENCE(PI_PRUEFLOS) TYPE  QALS-PRUEFLOS OPTIONAL
*"     REFERENCE(PI_LZNUM) TYPE  LTAK-LZNUM OPTIONAL
*"     REFERENCE(PI_USERNAME) TYPE  SY-UNAME OPTIONAL
*"     REFERENCE(PI_WERKS) TYPE  T001W-WERKS OPTIONAL
*"     REFERENCE(PI_MATNR) TYPE  MARA-MATNR OPTIONAL
*"     REFERENCE(PI_CHARG) TYPE  MCHB-CHARG OPTIONAL
*"     REFERENCE(PI_LGORT) TYPE  MCHB-LGORT OPTIONAL
*"     REFERENCE(PI_STCAT) TYPE  VAL_TEXT OPTIONAL
*"     REFERENCE(PI_IVNUM) TYPE  LVS_IVNUM OPTIONAL
*"     REFERENCE(PI_MENGE) TYPE  CHAR20 OPTIONAL
*"     REFERENCE(PI_VLTYP) TYPE  LTAP-VLTYP OPTIONAL
*"     REFERENCE(PI_VLPLA) TYPE  LTAP-VLPLA OPTIONAL
*"  EXPORTING
*"     REFERENCE(PE_PUTAWAY) TYPE  ZHGWMST001
*"     REFERENCE(PE_PICKSYS) TYPE  ZHGWMST004
*"     REFERENCE(PE_REPLENISH) TYPE  ZHGWMST019
*"     REFERENCE(PE_PIDDATA) TYPE  ZHGWMST007
*"     REFERENCE(PE_MATERIALSW) TYPE  ZHGWMST013
*"     REFERENCE(PE_IVNUM) TYPE  ZTSPMMDT006-IVNUM
*"     REFERENCE(PE_PIDYEAR) TYPE  ZHGWMST015
*"     REFERENCE(PE_TYPE) TYPE  CHAR1
*"     REFERENCE(PE_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      PT_TO STRUCTURE  ZHGWMST002 OPTIONAL
*"      PT_TOSYS STRUCTURE  ZHGWMST003 OPTIONAL
*"      PT_STP STRUCTURE  ZHGWMST005 OPTIONAL
*"      PT_SLOC STRUCTURE  ZHGWMST008 OPTIONAL
*"      PT_STCAT STRUCTURE  ZHGWMST009 OPTIONAL
*"      PT_PRINTER STRUCTURE  ZHGWMST010 OPTIONAL
*"      PT_REASON STRUCTURE  ZHGWMST011 OPTIONAL
*"      PT_SCAN STRUCTURE  ZHGWMST012 OPTIONAL
*"      PT_PIDITEM STRUCTURE  ZHGWMST014 OPTIONAL
*"      PT_PIDYEAR STRUCTURE  ZHGWMST016 OPTIONAL
*"      PT_LISTDN STRUCTURE  ZHGWMST017 OPTIONAL
*"      PT_LISTITEM STRUCTURE  ZHGWMST018 OPTIONAL
*"      PT_REPLENISH STRUCTURE  ZHGWMST020 OPTIONAL
*"      PT_POSTREPL STRUCTURE  ZHGWMST021 OPTIONAL
*"----------------------------------------------------------------------
  CASE pi_process.
    WHEN 'GETPUTAWAY'.
      PERFORM f_get_putaway USING pi_lgnum pi_prueflos pi_lznum pi_menge
                            CHANGING pe_putaway pe_type pe_message.

    WHEN 'GETDN'.
      PERFORM f_get_dn TABLES pt_listitem
                             USING pi_lgnum pi_tanum
                            CHANGING pe_type pe_message.

    WHEN 'GETDETAILDN'.
      PERFORM f_get_detaildn TABLES pt_listdn
                             USING pi_lgnum pi_charg pi_matnr pi_lznum pi_vltyp pi_vlpla
                            CHANGING pe_type pe_message.

    WHEN 'POSTPUTAWAY'.
      PERFORM f_post_putaway TABLES pt_to
                             USING pi_data
                             CHANGING pe_type pe_message.

    WHEN 'CONFPUTAWAY'.
      PERFORM f_confim_putaway TABLES pt_to
                               USING pi_data
                               CHANGING pe_type pe_message.

    WHEN 'CONFIRM'.
      PERFORM f_confirm USING pi_data
                        CHANGING pe_type pe_message.

    WHEN 'GETPICKING_SYS'.
      PERFORM f_get_picking_system_guide TABLES pt_tosys
                                         USING pi_username
                                         CHANGING pe_picksys
                                                  pe_type pe_message.

    WHEN 'GETSTP'.
      PERFORM f_get_stp TABLES pt_stp
                        USING pi_lgnum pi_tanum
                        CHANGING pe_type pe_message.

    WHEN 'GETPIDDATA'.
      PERFORM f_get_pid_data USING pi_username pi_lgnum pi_werks
                             CHANGING pe_piddata
                                      pe_type pe_message.

    WHEN 'GET_SLOC'.
      PERFORM f_get_sloc TABLES pt_sloc
                         USING pi_werks
                         CHANGING pe_type pe_message.

    WHEN 'GET_STCAT'.
      PERFORM f_get_stcat TABLES pt_stcat
                          CHANGING pe_type pe_message.

    WHEN 'GET_PRINTER'.
      PERFORM f_get_printer TABLES pt_printer
                            USING pi_username
                            CHANGING pe_type pe_message.

    WHEN 'GET_REASON'.
      PERFORM f_get_reason TABLES pt_reason
                           USING pi_werks
                           CHANGING pe_type pe_message.

    WHEN 'GET_SCAN'.
      PERFORM f_get_scan TABLES pt_scan
                         USING pi_lgnum
                         CHANGING pe_type pe_message.

    WHEN 'GETMATERIAL_SW'.
      PERFORM f_get_material_sw USING pi_werks pi_matnr pi_charg pi_lgort pi_stcat
                                CHANGING pe_materialsw pe_type pe_message.

    WHEN 'POSTPID_ADHOC'.
      PERFORM f_post_pidadhoc TABLES pt_piditem
                              USING pi_data
                              CHANGING pe_ivnum pe_type pe_message.

    WHEN 'PIDYEARLY'.
      PERFORM f_pid_yearly USING pi_werks pi_ivnum
                           CHANGING pe_pidyear pe_type pe_message.

    WHEN 'PIDITEM_YEARLY'.
      PERFORM f_piditem_yearly TABLES pt_pidyear
                               USING pi_werks pi_ivnum
                               CHANGING pe_type pe_message.

    WHEN 'POST_PIDYEARLY'.
      PERFORM f_post_pid_yearly TABLES pt_pidyear
                                USING pi_data
                                CHANGING pe_type pe_message.

    WHEN 'GETREPLENISH_SYS'.
      PERFORM f_get_replenish_system_guide TABLES pt_replenish
                                           USING pi_username
                                           CHANGING pe_replenish
                                                    pe_type pe_message.

    WHEN 'CONFREPLENISH_SYS'.
      PERFORM f_conf_replenish_system_guide TABLES pt_postrepl
                                            USING pi_data
                                            CHANGING pe_replenish
                                                     pe_type pe_message.

  ENDCASE.
ENDFUNCTION.
