  CLASS zihqm_cl004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

    PUBLIC SECTION.
      TYPES: BEGIN OF ty_qals,
               prueflos TYPE qplos,
               matnr    TYPE matnr,
               charg    TYPE charg_d,
               objnr    TYPE j_objnr,
               plnty    TYPE plnty,
               plnnr    TYPE plnnr,
               plnal    TYPE plnal,
               aufpl    TYPE co_aufpl,
             END OF ty_qals.
      TYPES tt_qals TYPE STANDARD TABLE OF ty_qals WITH DEFAULT KEY.

      TYPES: BEGIN OF ty_plpo,
               plnty TYPE plnty,
               plnnr TYPE plnnr,
               plnkn TYPE plnkn,
               zaehl TYPE cim_count,
               vornr TYPE vornr,
               steus TYPE steus,
               phflg TYPE phflg,
               ltxa1 TYPE ltxa1,
             END OF ty_plpo.
      TYPES tt_plpo TYPE STANDARD TABLE OF ty_plpo WITH DEFAULT KEY.

      TYPES: BEGIN OF ty_sample,
               insplot    TYPE qibplosnr,
               inspoper   TYPE qibpvornr,
               inspchar   TYPE qibpmerknr,
               inspsample TYPE qibpprobe,
               mean_value TYPE qmean_val,
             END OF ty_sample.
      TYPES tt_sample TYPE STANDARD TABLE OF ty_sample WITH DEFAULT KEY.

      TYPES: BEGIN OF ty_qasr,
               prueflos       TYPE qplos,
               vorglfnr       TYPE qlfnkn,
               merknr         TYPE qmerknrp,
               probenr        TYPE qstipronr,
               katalgart1     TYPE qkatausw,
               gruppe1        TYPE qcodegrp,
               code1          TYPE qcode,
               original_input TYPE qoriginal_input,
             END OF ty_qasr.
      TYPES tt_qasr TYPE STANDARD TABLE OF ty_qasr WITH DEFAULT KEY.

      TYPES: BEGIN OF ty_qamr,
               prueflos   TYPE qplos,
               vorglfnr   TYPE qlfnkn,
               merknr     TYPE qmerknrp,
               mittelwert TYPE qmittelwrt,
             END OF ty_qamr.
      TYPES tt_qamr TYPE STANDARD TABLE OF ty_qamr WITH DEFAULT KEY.

      TYPES: BEGIN OF ty_qpct,
               katalogart TYPE qkatart,
               codegruppe TYPE qcodegrp,
               code       TYPE qcode,
               kurztext   TYPE qtxt_code,
             END OF ty_qpct.
      TYPES tt_qpct TYPE STANDARD TABLE OF ty_qpct WITH DEFAULT KEY.

      TYPES: BEGIN OF ty_qamv,
               prueflos TYPE qplos,
               vorglfnr TYPE qlfnkn,
               merknr   TYPE qmerknrp,
               kurztext TYPE qmkkurztxt,
             END OF ty_qamv.
      TYPES tt_qamv TYPE STANDARD TABLE OF ty_qamv WITH DEFAULT KEY.

      TYPES: BEGIN OF ty_out,
               matnr TYPE matnr,
             END OF ty_out.
      TYPES tt_out TYPE STANDARD TABLE OF ty_out WITH DEFAULT KEY.

      TYPES: BEGIN OF ty_key,
               prueflos TYPE qplos,
               vorglfnr TYPE qlfnkn,
               merknr   TYPE qmerknrp,
             END OF ty_key.
      TYPES tt_key TYPE STANDARD TABLE OF ty_key WITH DEFAULT KEY.

      TYPES: iv_werks TYPE werks_d,
             iv_matnr TYPE matnr,
             iv_verwm TYPE qpmk-mkmnr,
             tr_charg TYPE RANGE OF qals-charg,
             tr_erste TYPE RANGE OF qasr-erstelldat,
             tt_plmk  TYPE STANDARD TABLE OF plmk WITH DEFAULT KEY,
             tt_qase  TYPE STANDARD TABLE OF qase WITH DEFAULT KEY.

      CLASS-METHODS validate_screen
        IMPORTING
          iv_werks TYPE iv_werks
          iv_matnr TYPE iv_matnr
          iv_verwm TYPE iv_verwm
        CHANGING
          ct_erste TYPE tr_erste.

      CLASS-METHODS execute
        IMPORTING
          ip_werks TYPE iv_werks
          ip_matnr TYPE iv_matnr
          ip_verwm TYPE iv_verwm
          it_charg TYPE tr_charg
          it_erste TYPE tr_erste.

    PROTECTED SECTION.

    PRIVATE SECTION.
      CLASS-DATA: go_alv TYPE REF TO cl_salv_table.

      CLASS-DATA: gv_maktx      TYPE maktx,
                  gv_rec        TYPE i,
                  gv_katalgart1 TYPE qkatausw.

      CLASS-DATA: gv_headl1 TYPE string,
                  gv_headl2 TYPE string,
                  gv_headl3 TYPE string,
                  gv_headl4 TYPE string.

      CLASS-DATA: gt_dyn_fcat     TYPE lvc_t_fcat,
                  gt_dyn_table    TYPE REF TO data,
                  gt_alv_fieldcat TYPE slis_t_fieldcat_alv.

      CLASS-DATA: gt_qals   TYPE tt_qals,
                  gt_plmk   TYPE tt_plmk,
                  gt_plpo   TYPE tt_plpo,
                  gt_sample TYPE tt_sample,
                  gt_qase   TYPE tt_qase,
                  gt_qasr   TYPE tt_qasr,
                  gt_qamr   TYPE tt_qamr,
                  gt_qpct   TYPE tt_qpct,
                  gt_qamv   TYPE tt_qamv,
                  gt_out    TYPE tt_out.

      " Alur Proses Internal (Modularisasi dari START-OF-SELECTION)
      CLASS-METHODS init_data
        IMPORTING
          ip_werks TYPE iv_werks
          ip_matnr TYPE iv_matnr
          ip_verwm TYPE iv_verwm
          it_erste TYPE tr_erste.

      CLASS-METHODS get_data
        IMPORTING
          ip_werks TYPE iv_werks
          ip_matnr TYPE iv_matnr
          ip_verwm TYPE iv_verwm
          it_charg TYPE tr_charg
          it_erste TYPE tr_erste.

      CLASS-METHODS crt_dyn_int_table.

      CLASS-METHODS process_data.

      CLASS-METHODS print_data.

      CLASS-METHODS free_memory.

      CLASS-METHODS handle_user_command
                  FOR EVENT added_function OF cl_salv_events_table
        IMPORTING e_salv_function.

      CLASS-METHODS single_chart.
      CLASS-METHODS mean_chart.

  ENDCLASS.


  CLASS zihqm_cl004 IMPLEMENTATION.
    METHOD execute.
      init_data( ip_werks = ip_werks
                 ip_matnr = ip_matnr
                 ip_verwm = ip_verwm
                 it_erste = it_erste ).

      get_data( ip_werks = ip_werks
                ip_matnr = ip_matnr
                ip_verwm = ip_verwm
                it_charg = it_charg
                it_erste = it_erste ).

      crt_dyn_int_table( ).
      process_data( ).
      print_data( ).
      free_memory( ).
    ENDMETHOD.


    METHOD validate_screen.
      DATA: lv_erste TYPE sy-datum,
            lv_mess  TYPE string.

      IF iv_werks IS INITIAL OR iv_matnr IS INITIAL OR iv_verwm IS INITIAL.
        MESSAGE 'Fill in all required entry fields' TYPE 'E'.
        RETURN.
      ENDIF.

      IF ct_erste IS INITIAL.
        MESSAGE 'Fill in all required entry fields' TYPE 'E'.
        RETURN.
      ENDIF.

      READ TABLE ct_erste ASSIGNING FIELD-SYMBOL(<fs_erste>) INDEX 1.
      IF sy-subrc = 0.
        lv_erste = <fs_erste>-low.

        " Hitung 12 bulan ke depan
        DO 12 TIMES.
          CALL FUNCTION 'LAST_DAY_OF_MONTHS'
            EXPORTING
              day_in            = lv_erste
            IMPORTING
              last_day_of_month = lv_erste
            EXCEPTIONS
              day_in_no_date    = 1
              OTHERS            = 2.
          IF sy-subrc <> 0.
            " Handle error jika input date tidak valid
            MESSAGE 'Invalid Date Input' TYPE 'E'.
            RETURN.
          ENDIF.
          lv_erste = lv_erste + 1.
        ENDDO.

        IF <fs_erste>-high IS NOT INITIAL.
          IF <fs_erste>-high >= lv_erste.
            MESSAGE 'Lot created on only for 1 year' TYPE 'E'.
          ENDIF.
        ELSE.
          <fs_erste>-high   = lv_erste.
          <fs_erste>-option = 'BT'.
        ENDIF.
      ENDIF.
    ENDMETHOD.


    METHOD init_data.
      DATA: lv_low   TYPE char10,
            lv_high  TYPE char10,
            lv_name1 TYPE t001w-name1,
            lv_maktx TYPE makt-maktx,
            lv_qpmt  TYPE qpmt-kurztext.

      CLEAR: gt_qals, gt_plmk, gt_plpo, gt_qasr, gt_qamr, gt_qpct, gt_qamv, gt_dyn_fcat,
             gv_headl1, gv_headl2, gv_headl3, gv_headl4.
      FREE:  gt_dyn_table.

      SELECT SINGLE name1 FROM t001w INTO @lv_name1 WHERE werks = @ip_werks.
      IF sy-subrc = 0.
        gv_headl1 = |{ ip_werks } - { lv_name1 }|.
      ELSE.
        gv_headl1 = |{ ip_werks }|.
      ENDIF.

      SELECT SINGLE maktx FROM makt INTO @lv_maktx WHERE matnr = @ip_matnr AND spras = @sy-langu.
      IF sy-subrc = 0.
        gv_headl2 = |{ ip_matnr } - { lv_maktx }|.
      ELSE.
        gv_headl2 = |{ ip_matnr }|.
      ENDIF.

      READ TABLE it_erste ASSIGNING FIELD-SYMBOL(<fs_erste>) INDEX 1.
      IF sy-subrc = 0.
        WRITE <fs_erste>-low  TO lv_low  DD/MM/YYYY.
        WRITE <fs_erste>-high TO lv_high DD/MM/YYYY.
        gv_headl3 = |{ lv_low } - { lv_high }|.
      ENDIF.

      SELECT SINGLE kurztext FROM qpmt
        INTO @lv_qpmt
        WHERE zaehler = @ip_werks
          AND mkmnr   = @ip_verwm
          AND version = '000001'
          AND sprache = @sy-langu.
      IF sy-subrc = 0.
        gv_headl4 = |{ ip_verwm } - { lv_qpmt }|.
      ELSE.
        gv_headl4 = |{ ip_verwm }|.
      ENDIF.
    ENDMETHOD.


    METHOD get_data.
      SELECT SINGLE maktx
        FROM makt
        INTO @gv_maktx
        WHERE matnr = @ip_matnr
          AND spras = @sy-langu.

      CASE ip_werks.
        WHEN '0401'.
          SELECT prueflos, matnr, charg, objnr, plnty, plnnr, plnal, aufpl
            FROM qals
            INTO TABLE @gt_qals
            WHERE werk      = @ip_werks
              AND charg     IN @it_charg
              AND matnr     = @ip_matnr
              AND ersteldat IN @it_erste.
        WHEN OTHERS.
          SELECT prueflos, matnr, charg, objnr, plnty, plnnr, plnal, aufpl
            FROM qals
            INTO TABLE @gt_qals
            WHERE werk      = @ip_werks
              AND art       = '03'
              AND charg     IN @it_charg
              AND matnr     = @ip_matnr
              AND ersteldat IN @it_erste
              AND plnty     = '2'.
      ENDCASE.

      IF gt_qals IS INITIAL.
        RETURN.
      ENDIF.

      " Validasi System Status (Pengganti f_validate_system_status)
      SELECT jest~objnr, jest~stat, tj02t~txt04
        FROM jest
        INNER JOIN tj02t ON jest~stat = tj02t~istat
        INTO TABLE @DATA(lt_jest)
        FOR ALL ENTRIES IN @gt_qals
        WHERE jest~objnr = @gt_qals-objnr
          AND jest~inact = @space
          AND tj02t~txt04 IN ('REC', 'RREC')
          AND tj02t~spras = @sy-langu.

      " Eliminasi data QALS jika status pencocokan > 2
      LOOP AT gt_qals ASSIGNING FIELD-SYMBOL(<fs_qals>).
        DATA(lv_count_status) = 0.
        LOOP AT lt_jest ASSIGNING FIELD-SYMBOL(<fs_jest>) WHERE objnr = <fs_qals>-objnr.
          lv_count_status = lv_count_status + 1.
        ENDLOOP.

        IF lv_count_status > 2.
          DELETE gt_qals. " Hapus record dari internal table utama
        ENDIF.
      ENDLOOP.

      IF gt_qals IS INITIAL.
        RETURN.
      ENDIF.

      SELECT *
        FROM plmk
        INTO TABLE @gt_plmk
        FOR ALL ENTRIES IN @gt_qals
        WHERE plnty     = @gt_qals-plnty
          AND plnnr     = @gt_qals-plnnr
          AND verwmerkm = @ip_verwm.

      IF gt_plmk IS INITIAL.
        RETURN.
      ENDIF.

      CASE ip_werks.
        WHEN '0401'.
          SELECT plnty, plnnr, plnkn, zaehl, vornr, steus, phflg, ltxa1
            FROM plpo
            INTO TABLE @gt_plpo
            FOR ALL ENTRIES IN @gt_plmk
            WHERE plnty = @gt_plmk-plnty
              AND plnnr = @gt_plmk-plnnr
              AND plnkn = @gt_plmk-plnkn.
        WHEN OTHERS.
          SELECT plnty, plnnr, plnkn, zaehl, vornr, steus, phflg, ltxa1
            FROM plpo
            INTO TABLE @gt_plpo
            FOR ALL ENTRIES IN @gt_plmk
            WHERE plnty = @gt_plmk-plnty
              AND plnnr = @gt_plmk-plnnr
              AND plnkn = @gt_plmk-plnkn
              AND steus = 'ZQ01'
              AND phflg = 'X'.
      ENDCASE.

      DATA: lt_key TYPE tt_key,
            ls_key TYPE ty_key.

      LOOP AT gt_qals ASSIGNING FIELD-SYMBOL(<fs_qals_map>).
        LOOP AT gt_plmk ASSIGNING FIELD-SYMBOL(<fs_plmk>) WHERE plnty = <fs_qals_map>-plnty
                                                           AND plnnr = <fs_qals_map>-plnnr.
          ls_key-prueflos = <fs_qals_map>-prueflos.
          ls_key-merknr   = <fs_plmk>-merknr.

          LOOP AT gt_plpo ASSIGNING FIELD-SYMBOL(<fs_plpo>) WHERE plnty = <fs_plmk>-plnty
                                                             AND plnnr = <fs_plmk>-plnnr
                                                             AND plnkn = <fs_plmk>-plnkn.
            CALL FUNCTION 'QIBP_GET_VORGLFNR'
              EXPORTING
                i_insp_lot           = <fs_qals_map>-prueflos
                i_oper_no            = <fs_plpo>-vornr
              IMPORTING
                e_vorglfnr           = ls_key-vorglfnr
              EXCEPTIONS
                wrong_inspection_lot = 1
                wrong_operation_no   = 2
                OTHERS               = 3.
            IF sy-subrc = 0.
              APPEND ls_key TO lt_key.
            ENDIF.
          ENDLOOP.
          CLEAR ls_key.
        ENDLOOP.
      ENDLOOP.

      SORT lt_key BY prueflos vorglfnr merknr.
      DELETE ADJACENT DUPLICATES FROM lt_key COMPARING ALL FIELDS.

      IF lt_key IS INITIAL.
        RETURN.
      ENDIF.

      READ TABLE gt_plmk ASSIGNING FIELD-SYMBOL(<fs_first_plmk>) INDEX 1.
      IF sy-subrc = 0.
        gv_katalgart1 = <fs_first_plmk>-katalgart1.
      ENDIF.

      TYPES: BEGIN OF ty_rec,
               prueflos TYPE qplos,
               count    TYPE i,
             END OF ty_rec.
      DATA: lt_rec TYPE STANDARD TABLE OF ty_rec WITH DEFAULT KEY,
            ls_rec TYPE ty_rec.

      IF gv_katalgart1 = '1'.
        SELECT prueflos, vorglfnr, merknr, probenr, katalgart1, gruppe1, code1, original_input
          FROM qasr
          INTO TABLE @gt_qasr
          FOR ALL ENTRIES IN @lt_key
          WHERE prueflos = @lt_key-prueflos
            AND vorglfnr = @lt_key-vorglfnr
            AND merknr   = @lt_key-merknr.

        IF gt_qasr IS NOT INITIAL.
          DATA(lt_qasr_dist) = gt_qasr.
          SORT lt_qasr_dist BY katalgart1 gruppe1 code1.
          DELETE ADJACENT DUPLICATES FROM lt_qasr_dist COMPARING katalgart1 gruppe1 code1.

          SELECT katalogart, codegruppe, code, kurztext
            FROM qpct
            INTO TABLE @gt_qpct
            FOR ALL ENTRIES IN @lt_qasr_dist
            WHERE katalogart  = @lt_qasr_dist-katalgart1
              AND codegruppe  = @lt_qasr_dist-gruppe1
              AND code        = @lt_qasr_dist-code1
              AND sprache     = @sy-langu.

          " Hitung jumlah record per lot (Collect)
          LOOP AT gt_qasr ASSIGNING FIELD-SYMBOL(<fs_qasr>).
            ls_rec-prueflos = <fs_qasr>-prueflos.
            ls_rec-count    = 1.
            COLLECT ls_rec INTO lt_rec.
          ENDLOOP.
        ENDIF.

      ELSE.
        SELECT *
          FROM qase
          INTO CORRESPONDING FIELDS OF TABLE @gt_qase
          FOR ALL ENTRIES IN @lt_key
          WHERE prueflos = @lt_key-prueflos
            AND vorglfnr = @lt_key-vorglfnr
            AND merknr   = @lt_key-merknr.

        " Hitung jumlah record per lot (Collect)
        LOOP AT gt_qase ASSIGNING FIELD-SYMBOL(<fs_qase>).
          ls_rec-prueflos = <fs_qase>-prueflos.
          ls_rec-count    = 1.
          COLLECT ls_rec INTO lt_rec.
        ENDLOOP.
      ENDIF.

      " Ambil nilai count tertinggi
      IF lt_rec IS NOT INITIAL.
        SORT lt_rec BY count DESCENDING.
        READ TABLE lt_rec ASSIGNING FIELD-SYMBOL(<fs_max_rec>) INDEX 1.
        IF sy-subrc = 0.
          gv_rec = <fs_max_rec>-count.
        ENDIF.
      ENDIF.
    ENDMETHOD.


    METHOD crt_dyn_int_table.
      DATA: ls_fcat     TYPE lvc_s_fcat,
            ls_alv_fcat TYPE slis_fieldcat_alv,
            lv_pos      TYPE i,
            lv_count    TYPE qstipronr,
            lv_coltext  TYPE string.

      CLEAR: gt_dyn_fcat, gt_alv_fieldcat.
      FREE:  gt_dyn_table.

      " Tambahkan Kolom Standar Utama ke Field Catalog (LVC)
      " Kolom CHECK (Checkbox)
      CLEAR ls_fcat.
      ls_fcat-fieldname = 'CHECK'.
      ls_fcat-checkbox  = 'X'.
      ls_fcat-no_out    = 'X'.
      APPEND ls_fcat TO gt_dyn_fcat.

      " Kolom PRUEFLOS
      CLEAR ls_fcat.
      ls_fcat-fieldname = 'PRUEFLOS'.
      ls_fcat-ref_field = 'PRUEFLOS'.
      ls_fcat-ref_table = 'QALS'.
      APPEND ls_fcat TO gt_dyn_fcat.

      " Kolom CHARG
      CLEAR ls_fcat.
      ls_fcat-fieldname = 'CHARG'.
      ls_fcat-ref_field = 'CHARG'.
      ls_fcat-ref_table = 'QALS'.
      APPEND ls_fcat TO gt_dyn_fcat.

      " Kolom VORNR
      CLEAR ls_fcat.
      ls_fcat-fieldname = 'VORNR'.
      ls_fcat-ref_field = 'VORNR'.
      ls_fcat-ref_table = 'PLPO'.
      APPEND ls_fcat TO gt_dyn_fcat.

      " Kolom LTXA1 (Operation Long Text)
      CLEAR ls_fcat.
      ls_fcat-fieldname = 'LTXA1'.
      ls_fcat-outputlen = 40.
      ls_fcat-scrtext_l = 'Operation'.
      ls_fcat-scrtext_m = 'Operation'.
      ls_fcat-scrtext_s = 'Operation'.
      APPEND ls_fcat TO gt_dyn_fcat.

      " Tambahkan Kolom Dinamis
      DO gv_rec TIMES.
        lv_count = lv_count + 1.
        lv_coltext = |{ lv_count ALPHA = OUT }|.

        " Kolom Nilai Sampel (OI_x)
        CLEAR ls_fcat.
        ls_fcat-fieldname   = |OI{ lv_count }|.
        ls_fcat-scrtext_l   = |Sample { lv_coltext }|.
        ls_fcat-scrtext_m   = |Sample { lv_coltext }|.
        ls_fcat-scrtext_s   = |Sample { lv_coltext }|.
        ls_fcat-datatype    = 'QUAN'.
        ls_fcat-qfieldname  = |MEINS{ lv_count }|.
        APPEND ls_fcat TO gt_dyn_fcat.

        CLEAR ls_fcat.
        ls_fcat-fieldname   = |MEINS{ lv_count }|.
        ls_fcat-no_out      = 'X'.
        APPEND ls_fcat TO gt_dyn_fcat.
      ENDDO.

      " 3. Generate Internal Table Dinamis di Runtime Memory
      cl_alv_table_create=>create_dynamic_table(
        EXPORTING
          i_style_table             = 'X'
          it_fieldcatalog           = gt_dyn_fcat
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = gt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2 ).

      IF sy-subrc <> 0.
        MESSAGE 'Gagal membuat tabel internal dinamis.' TYPE 'E'.
        RETURN.
      ENDIF.

      " Konversi & Mapping dari LVC_T_FCAT ke SLIS_T_FIELDCAT_ALV
      LOOP AT gt_dyn_fcat ASSIGNING FIELD-SYMBOL(<fs_lvc>).
        lv_pos = lv_pos + 1.
        CLEAR ls_alv_fcat.

        ls_alv_fcat-fieldname     = <fs_lvc>-fieldname.
        ls_alv_fcat-tabname       = <fs_lvc>-tabname.
        ls_alv_fcat-seltext_l     = <fs_lvc>-scrtext_l.
        ls_alv_fcat-seltext_m     = <fs_lvc>-scrtext_m.
        ls_alv_fcat-seltext_s     = <fs_lvc>-scrtext_s.
        ls_alv_fcat-outputlen     = <fs_lvc>-outputlen.
        ls_alv_fcat-col_pos       = lv_pos.
        ls_alv_fcat-do_sum        = <fs_lvc>-do_sum.
        ls_alv_fcat-emphasize     = <fs_lvc>-emphasize.
        ls_alv_fcat-key           = <fs_lvc>-key.
        ls_alv_fcat-no_out        = <fs_lvc>-no_out.
        ls_alv_fcat-ref_fieldname = <fs_lvc>-ref_field.
        ls_alv_fcat-ref_tabname   = <fs_lvc>-ref_table.
        ls_alv_fcat-inttype       = <fs_lvc>-inttype.
        ls_alv_fcat-decimals_out  = <fs_lvc>-decimals_o.
        ls_alv_fcat-qfieldname    = <fs_lvc>-qfieldname.
        ls_alv_fcat-checkbox      = <fs_lvc>-checkbox.
        ls_alv_fcat-edit          = <fs_lvc>-edit.

        APPEND ls_alv_fcat TO gt_alv_fieldcat.
      ENDLOOP.
    ENDMETHOD.


    METHOD process_data.
      DATA: lv_fieldname TYPE lvc_fname,
            lv_count     TYPE qstipronr,
            lv_num       TYPE z19_3.

      FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE,
                     <ls_row>   TYPE any,
                     <lv_field> TYPE any.

      ASSIGN gt_dyn_table->* TO <lt_table>.
      IF <lt_table> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      SORT gt_qasr BY prueflos vorglfnr merknr probenr.
      SORT gt_qase BY prueflos detailerg.

      DATA: lo_table_desc TYPE REF TO cl_abap_tabledescr,
            lo_struct     TYPE REF TO cl_abap_structdescr.

      lo_table_desc ?= cl_abap_typedescr=>describe_by_data( <lt_table> ).
      lo_struct     ?= lo_table_desc->get_table_line_type( ).

      DATA: lr_row TYPE REF TO data.
      CREATE DATA lr_row TYPE HANDLE lo_struct.
      ASSIGN lr_row->* TO <ls_row>.

      LOOP AT gt_qals ASSIGNING FIELD-SYMBOL(<fs_qals>).

        LOOP AT gt_plpo ASSIGNING FIELD-SYMBOL(<fs_plpo>)
          WHERE plnty = <fs_qals>-plnty
            AND plnnr = <fs_qals>-plnnr.

          CLEAR: <ls_row>, lv_count.

          " Isi field standar: PRUEFLOS
          ASSIGN COMPONENT 'PRUEFLOS' OF STRUCTURE <ls_row> TO <lv_field>.
          IF sy-subrc = 0. <lv_field> = <fs_qals>-prueflos. ENDIF.

          " Isi field standar: CHARG
          ASSIGN COMPONENT 'CHARG' OF STRUCTURE <ls_row> TO <lv_field>.
          IF sy-subrc = 0. <lv_field> = <fs_qals>-charg. ENDIF.

          " Isi field standar: VORNR
          ASSIGN COMPONENT 'VORNR' OF STRUCTURE <ls_row> TO <lv_field>.
          IF sy-subrc = 0. <lv_field> = <fs_plpo>-vornr. ENDIF.

          " Isi field standar: LTXA1
          ASSIGN COMPONENT 'LTXA1' OF STRUCTURE <ls_row> TO <lv_field>.
          IF sy-subrc = 0. <lv_field> = <fs_plpo>-ltxa1. ENDIF.

          IF gv_katalgart1 = '1'.
            LOOP AT gt_qasr ASSIGNING FIELD-SYMBOL(<fs_qasr>)
              WHERE prueflos = <fs_qals>-prueflos.

              lv_count = lv_count + 1.
              lv_fieldname = |OI{ lv_count }|.

              READ TABLE gt_qpct ASSIGNING FIELD-SYMBOL(<fs_qpct>)
                WITH KEY katalogart = <fs_qasr>-katalgart1
                         codegruppe = <fs_qasr>-gruppe1
                         code       = <fs_qasr>-code1.
              IF sy-subrc = 0.
                <fs_qasr>-original_input = |{ <fs_qasr>-code1 } { <fs_qpct>-kurztext }|.
              ENDIF.

              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_row> TO <lv_field>.
              IF sy-subrc = 0.
                CLEAR lv_num.
                CALL FUNCTION 'MOVE_CHAR_TO_NUM'
                  EXPORTING
                    chr             = <fs_qasr>-original_input
                  IMPORTING
                    num             = lv_num
                  EXCEPTIONS
                    convt_no_number = 1
                    convt_overflow  = 2
                    OTHERS          = 3.

                IF sy-subrc = 0.
                  <lv_field> = lv_num.
                ELSE.
                  <lv_field> = <fs_qasr>-original_input.
                ENDIF.
              ENDIF.

              lv_fieldname = |MEINS{ lv_count }|.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_row> TO <lv_field>.
              IF sy-subrc = 0.
                <lv_field> = 'X'.
              ENDIF.
            ENDLOOP.

          ELSE.
            LOOP AT gt_qase ASSIGNING FIELD-SYMBOL(<fs_qase>)
              WHERE prueflos = <fs_qals>-prueflos.

              lv_count = lv_count + 1.
              lv_fieldname = |OI{ lv_count }|.

              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_row> TO <lv_field>.
              IF sy-subrc = 0.
                DATA(lv_input_clean) = <fs_qase>-original_input.
                CONDENSE lv_input_clean NO-GAPS.
                CLEAR lv_num.
                CALL FUNCTION 'MOVE_CHAR_TO_NUM'
                  EXPORTING
                    chr             = lv_input_clean
                  IMPORTING
                    num             = lv_num
                  EXCEPTIONS
                    convt_no_number = 1
                    convt_overflow  = 2
                    OTHERS          = 3.

                IF sy-subrc = 0.
                  <lv_field> = lv_num.
                ELSE.
                  <lv_field> = lv_input_clean.
                ENDIF.
              ENDIF.

              lv_fieldname = |MEINS{ lv_count }|.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_row> TO <lv_field>.
              IF sy-subrc = 0.
                <lv_field> = 'X'.
              ENDIF.
            ENDLOOP.
          ENDIF.

          " Insert to dinamis table
          APPEND <ls_row> TO <lt_table>.

        ENDLOOP.
      ENDLOOP.
    ENDMETHOD.


    METHOD print_data.
      DATA: lo_columns    TYPE REF TO cl_salv_columns_table,
            lo_column     TYPE REF TO cl_salv_column_table,
            lo_events     TYPE REF TO cl_salv_events_table,
            lo_selections TYPE REF TO cl_salv_selections,
            lo_header     TYPE REF TO cl_salv_form_layout_grid,
            lo_label      TYPE REF TO cl_salv_form_label,
            lo_text       TYPE REF TO cl_salv_form_text,
            lx_msg        TYPE REF TO cx_salv_msg.

      FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE.

      ASSIGN gt_dyn_table->* TO <lt_table>.
      IF <lt_table> IS NOT ASSIGNED OR <lt_table> IS INITIAL.
        MESSAGE 'No output data processed.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      TRY.
          cl_salv_table=>factory(
            IMPORTING
              r_salv_table = go_alv
            CHANGING
              t_table      = <lt_table> ).

          " Set GUI Status Standard
          go_alv->set_screen_status(
            report        = sy-cprog
            pfstatus      = 'STANDARD'
            set_functions = go_alv->c_functions_all ).

          lo_selections = go_alv->get_selections( ).
          lo_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

          " Registrasi Event Handler Toolbar & Klik Cell
          lo_events = go_alv->get_event( ).
          SET HANDLER zihqm_cl004=>handle_user_command FOR lo_events.

          lo_columns = go_alv->get_columns( ).
          lo_columns->set_optimize( abap_true ).

          " Sinkronisasi Label LVC
          LOOP AT gt_dyn_fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
            TRY.
                lo_column ?= lo_columns->get_column( <fs_fcat>-fieldname ).

                IF <fs_fcat>-scrtext_l IS NOT INITIAL.
                  lo_column->set_long_text( |{ <fs_fcat>-scrtext_l }| ).
                  lo_column->set_medium_text( |{ <fs_fcat>-scrtext_m }| ).
                  lo_column->set_short_text( |{ <fs_fcat>-scrtext_s }| ).
                ENDIF.

                " Ubah kolom CHECK menjadi Hotspot agar memicu event saat diklik
                IF <fs_fcat>-fieldname = 'CHECK'.
                  lo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
                ENDIF.

                IF <fs_fcat>-no_out = 'X'.
                  lo_column->set_visible( abap_false ).
                ENDIF.

              CATCH cx_salv_not_found.
            ENDTRY.
          ENDLOOP.

          go_alv->get_display_settings( )->set_list_header( sy-title ).


          " Layout Top of Page (Header)
          CREATE OBJECT lo_header.

          lo_header->create_header_information(
            row     = 1
            column  = 2
            text    = sy-title
          ).

          IF gv_headl1 IS NOT INITIAL.
            lo_label = lo_header->create_label( row = 2 column = 1 ).
            lo_label->set_text( 'Plant:' ).
            lo_text  = lo_header->create_text(  row = 2 column = 2 ).
            lo_text->set_text( gv_headl1 ).
          ENDIF.

          IF gv_headl2 IS NOT INITIAL.
            lo_label = lo_header->create_label( row = 3 column = 1 ).
            lo_label->set_text( 'Material:' ).
            lo_text  = lo_header->create_text(  row = 3 column = 2 ).
            lo_text->set_text( gv_headl2 ).
          ENDIF.

          IF gv_headl3 IS NOT INITIAL.
            lo_label = lo_header->create_label( row = 4 column = 1 ).
            lo_label->set_text( 'Date Period:' ).
            lo_text  = lo_header->create_text(  row = 4 column = 2 ).
            lo_text->set_text( gv_headl3 ).
          ENDIF.

          IF gv_headl4 IS NOT INITIAL.
            lo_label = lo_header->create_label( row = 5 column = 1 ).
            lo_label->set_text( 'Master Method:' ).
            lo_text  = lo_header->create_text(  row = 5 column = 2 ).
            lo_text->set_text( gv_headl4 ).
          ENDIF.

          go_alv->set_top_of_list( lo_header ).

          go_alv->display( ).

        CATCH cx_salv_msg INTO lx_msg.
          MESSAGE lx_msg->get_text( ) TYPE 'E'.
      ENDTRY.

    ENDMETHOD.

    METHOD free_memory.
      CLEAR: gt_out, gt_out[].
    ENDMETHOD.

    METHOD handle_user_command.

      CASE e_salv_function.
        WHEN '&SINGLE'.
          zihqm_cl004=>single_chart( ).
        WHEN '&MEAN'.
          zihqm_cl004=>mean_chart( ).
      ENDCASE.

    ENDMETHOD.

    METHOD single_chart.
      DATA : lt_qase                 TYPE STANDARD TABLE OF qase INITIAL SIZE 0,
             ls_qamv                 TYPE qamv,
             l_graphics_still_active TYPE qm00-qkz,
             lt_rows                 TYPE salv_t_row.

      FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE,
                     <lv_lot>   TYPE any.

      ASSIGN gt_dyn_table->* TO <lt_table>.
      IF <lt_table> IS NOT ASSIGNED. RETURN. ENDIF.

      IF go_alv IS BOUND.
        lt_rows = go_alv->get_selections( )->get_selected_rows( ).
      ENDIF.

      IF lt_rows IS INITIAL.
        MESSAGE 'Pilih minimal satu baris data terlebih dahulu.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      LOOP AT lt_rows INTO DATA(lv_row_idx).
        READ TABLE <lt_table> ASSIGNING FIELD-SYMBOL(<fs_row>) INDEX lv_row_idx.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'PRUEFLOS' OF STRUCTURE <fs_row> TO <lv_lot>.
          IF <lv_lot> IS ASSIGNED.
            LOOP AT gt_qase ASSIGNING FIELD-SYMBOL(<fs_qase>) WHERE prueflos = <lv_lot>.
              APPEND <fs_qase> TO lt_qase.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.

      SORT lt_qase BY prueflos DESCENDING.
      READ TABLE lt_qase ASSIGNING FIELD-SYMBOL(<fs_first_qase>) INDEX 1.
      IF sy-subrc = 0.
        SELECT SINGLE *
          FROM qamv
          INTO CORRESPONDING FIELDS OF @ls_qamv
          WHERE prueflos = @<fs_first_qase>-prueflos
            AND vorglfnr = @<fs_first_qase>-vorglfnr
            AND merknr   = @<fs_first_qase>-merknr.
      ENDIF.

      CALL FUNCTION 'QEGR_RUN_CHART_FOR_QASE'
        EXPORTING
          i_merknr                = ls_qamv-merknr
          i_kurztext              = ls_qamv-kurztext
          i_ktextmat              = gv_maktx
          i_masseinhsw3           = ls_qamv-masseinhsw
          i_stellen               = ls_qamv-stellen
          i_tolobni               = ls_qamv-tolobni
          i_toleranzob            = ls_qamv-toleranzob
          i_sollwni               = ls_qamv-sollwni
          i_sollwert              = ls_qamv-sollwert
          i_tolunni               = ls_qamv-tolunni
          i_toleranzun            = ls_qamv-toleranzun
        IMPORTING
          e_graphics_still_active = l_graphics_still_active
        TABLES
          t_qasetab               = lt_qase
        EXCEPTIONS
          missing_data            = 1
          inconsistent_data       = 2
          programming_error       = 3
          OTHERS                  = 4.
      IF sy-subrc <> 0.
        MESSAGE 'Gagal memproses Single Control Chart.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ENDMETHOD.


    METHOD mean_chart.
      TYPES: BEGIN OF t_mk_out.
               INCLUDE TYPE qgmk.
               TYPES:   decimals_out         TYPE slis_fieldcat_alv-decimals_out,
               dec_stat_out         TYPE slis_fieldcat_alv-decimals_out,
               dec_stat_inpproc_out TYPE slis_fieldcat_alv-decimals_out,
               lights               TYPE char1,
               selected             TYPE char1,
             END OF t_mk_out.

      DATA : lt_qase                  TYPE STANDARD TABLE OF qase INITIAL SIZE 0,
             l_xgraphics_still_active TYPE qm00-qkz,
             p_mk_outtab              TYPE STANDARD TABLE OF t_mk_out INITIAL SIZE 0,
             l_qgmk_tab               TYPE STANDARD TABLE OF qgmk INITIAL SIZE 0,
             l_qgmk                   TYPE qgmk,
             lt_rows                  TYPE salv_t_row.

      FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE,
                     <lv_lot>   TYPE any.

      ASSIGN gt_dyn_table->* TO <lt_table>.
      IF <lt_table> IS NOT ASSIGNED. RETURN. ENDIF.

      IF go_alv IS BOUND.
        lt_rows = go_alv->get_selections( )->get_selected_rows( ).
      ENDIF.

      IF lt_rows IS INITIAL.
        MESSAGE 'Pilih minimal satu baris data terlebih dahulu.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      lt_qase[] = gt_qase[].
      SORT lt_qase BY prueflos vorglfnr merknr.
      DELETE ADJACENT DUPLICATES FROM lt_qase COMPARING prueflos vorglfnr merknr.

      IF lt_qase IS NOT INITIAL.
        SELECT *
          FROM qamv
          INNER JOIN qamr ON qamv~prueflos = qamr~prueflos
                         AND qamv~vorglfnr = qamr~vorglfnr
                         AND qamv~merknr   = qamr~merknr
          INNER JOIN qasv ON qamv~prueflos = qasv~prueflos
                         AND qamv~vorglfnr = qasv~vorglfnr
                         AND qamv~merknr   = qasv~merknr
          INNER JOIN qals ON qamv~prueflos = qals~prueflos
          INTO CORRESPONDING FIELDS OF TABLE @p_mk_outtab
          FOR ALL ENTRIES IN @lt_qase
          WHERE qamv~prueflos = @lt_qase-prueflos
            AND qamv~vorglfnr = @lt_qase-vorglfnr
            AND qamv~merknr   = @lt_qase-merknr
            AND qasv~probenr  = '000000'.
      ENDIF.

      LOOP AT lt_rows INTO DATA(lv_row_idx).
        READ TABLE <lt_table> ASSIGNING FIELD-SYMBOL(<fs_row>) INDEX lv_row_idx.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'PRUEFLOS' OF STRUCTURE <fs_row> TO <lv_lot>.
          IF <lv_lot> IS ASSIGNED.
            LOOP AT p_mk_outtab ASSIGNING FIELD-SYMBOL(<fs_qgmk>) WHERE prueflos = <lv_lot>.
              DATA(ls_base_qgmk) = CORRESPONDING qgmk( <fs_qgmk> ).
              APPEND ls_base_qgmk TO l_qgmk_tab.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.

      SORT l_qgmk_tab BY prueflos DESCENDING.
      READ TABLE l_qgmk_tab INTO l_qgmk INDEX 1.

      CALL FUNCTION 'QEGR_RUN_CHART_FOR_QGMK'
        EXPORTING
          i_merknr                = l_qgmk-merknr
          i_kurztext              = l_qgmk-kurztext
          i_ktextmat              = gv_maktx
          i_masseinhsw6           = l_qgmk-masseinhsw
          i_stellen               = l_qgmk-stellen
          i_tolobni               = l_qgmk-tolobni
          i_sollwni               = l_qgmk-sollwni
          i_tolunni               = l_qgmk-tolunni
          i_time_axis             = ''
          i_page_size             = 20
        IMPORTING
          e_graphics_still_active = l_xgraphics_still_active
        TABLES
          t_qgmktab               = l_qgmk_tab
        EXCEPTIONS
          missing_data            = 1
          inconsistent_data       = 2
          programming_error       = 3
          OTHERS                  = 4.
      IF sy-subrc <> 0.
        MESSAGE 'Gagal memproses Mean Control Chart.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

    ENDMETHOD.
  ENDCLASS.
