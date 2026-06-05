***INCLUDE ZABPXIN_SCRIPT .

TABLES: tnapr.

CONSTANTS: c_lyt_yes VALUE 'X',
           c_lyt_no  VALUE space.

DATA: d_lyt_subrc LIKE sy-subrc,
      d_lyt_error VALUE c_lyt_no.

* Filing number data declaration
DATA:
*      d_lyt_count LIKE zpygxdt_nastflnr-counter,
*      d_lyt_flnum TYPE zpygxde_flnr,
*      d_lyt_objct LIKE zpygxdt_obidflnr-object VALUE 'ZPYG_FLNR',
      d_lyt_begda LIKE sy-datum,
      d_lyt_begtm LIKE sy-uzeit,
      d_lyt_datum LIKE sy-datum,
      d_lyt_pline,
      d_lyt_totpg TYPE i, "Total of page
      d_lyt_wtype(10) VALUE 'BODY',
      d_lyt_uzeit LIKE sy-uzeit.

* Page types
DATA: d_lyt_pgwin_one LIKE rsscf-tdeline,
      d_lyt_pgwin_two LIKE rsscf-tdeline,
      d_lyt_pgwin_next LIKE rsscf-tdeline,
      d_lyt_pgwin_last LIKE rsscf-tdeline.

* Maximum lines in one page
DATA: d_lyt_maxln_one TYPE i,
      d_lyt_maxln_two TYPE i,
      d_lyt_maxln_next TYPE i,
      d_lyt_maxln_last TYPE i.

* Maximum Pages in Form.
DATA: d_lyt_maxpg TYPE i.

* Layout Set data declaration
DATA: d_lyt_oncom LIKE sy-oncom,   "Communication type: V=Update Task
      d_lyt_nast TYPE nast,
      d_lyt_itcpp TYPE itcpp,
      d_lyt_tdimd VALUE 'X',  "Flag -> Print Immediately
      d_lyt_tddel VALUE 'X',  "Flag -> Delete Print Immediately
      d_lyt_tddst LIKE itcpo-tddest, "Spool: Output device
      d_lyt_itcpo TYPE itcpo.

DATA: d_lyt_pages TYPE i,
      d_lyt_spage TYPE i,
      d_lyt_epage TYPE i,
      d_lyt_tabix TYPE i,
      d_lyt_tfill TYPE i,
      d_lyt_tpage,              "Type of page: 'X'=Last
      d_lyt_lpage TYPE i.

*---------------------------------------------------------------------*
*       FORM F_LYT_CHECK_ERROR                                        *
*---------------------------------------------------------------------*
FORM f_lyt_check_error.
  d_lyt_subrc = sy-subrc.
  IF sy-subrc <> 0 OR d_lyt_error NE c_lyt_no.
    d_lyt_error = c_lyt_yes.
    IF sy-oncom EQ 'V'.  "In Update Task
      PERFORM f_lyt_protocol_update.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*  PERFORM f_execute(zabpxop_exec).
ENDFORM.

*---------------------------------------------------------------------*
*       FORM F_LYT_START_FORM                                         *
*---------------------------------------------------------------------*
FORM f_lyt_start_form USING fu_spage.
  CHECK d_lyt_error EQ c_lyt_no.
  CALL FUNCTION 'START_FORM'
       EXPORTING
            language  = sy-langu
            startpage = fu_spage
       IMPORTING
            language  = sy-langu
       EXCEPTIONS
            form      = 1
            format    = 2
            unended   = 3
            unopened  = 4
            unused    = 5
            OTHERS    = 6.
  PERFORM f_lyt_check_error.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_OPEN_FORM
*&---------------------------------------------------------------------*
*& @FU_FONAM: Form Name
*& @FU_PREVW: Print Preview ? X:=Yes
*& @FU_NOPRN: Hide Print Button in Preview mode ? X:= Yes
*&---------------------------------------------------------------------*
FORM f_lyt_open_form USING fu_fonam fu_prevw fu_noprn.
  DATA: ld_lyt_fonam LIKE tnapr-fonam.

  CHECK d_lyt_error EQ c_lyt_no.
  d_lyt_itcpo-tdpreview = fu_prevw.
  d_lyt_itcpo-tdnoprint = fu_noprn.
  ld_lyt_fonam          = fu_fonam.

  IF d_lyt_nast-anzal IS INITIAL.
    d_lyt_nast-anzal = 1.
  ENDIF.
  IF d_lyt_oncom EQ 'V'.
    MOVE-CORRESPONDING d_lyt_nast TO d_lyt_itcpo.
    d_lyt_itcpo-tdcover    = d_lyt_nast-tdocover.
    d_lyt_itcpo-tddest     = d_lyt_nast-ldest.
    d_lyt_itcpo-tddataset  = d_lyt_nast-dsnam.
    d_lyt_itcpo-tdsuffix1  = d_lyt_nast-dsuf1.
    d_lyt_itcpo-tdsuffix2  = d_lyt_nast-dsuf2.
    d_lyt_itcpo-tdimmed    = d_lyt_nast-dimme.
    d_lyt_itcpo-tddelete   = d_lyt_nast-delet.
    d_lyt_itcpo-tdcopies   = d_lyt_nast-anzal.
    d_lyt_itcpo-tdprogram  = sy-repid.
    d_lyt_itcpo-tdsenddate = d_lyt_nast-vsdat.
    d_lyt_itcpo-tdsendtime = d_lyt_nast-vsura.
    d_lyt_itcpo-tdnewid    = 'X'.
*    PERFORM f_cprog(zabpxop_exec) USING tnapr-pgnam.
*    if tnapr-pgnam = 'ZPYGLOP_MM_GOOD_RECEIPT_FORM'.
*      select single * from ZPYGLDT_FORM_MAP
*    endif.
*    ld_lyt_fonam           = tnapr-fonam.
  ELSE.
    d_lyt_itcpo-tdimmed    = d_lyt_tdimd.
    d_lyt_itcpo-tddelete   = d_lyt_tddel.
    d_lyt_itcpo-tdprogram  = sy-repid.
    d_lyt_itcpo-tdreceiver = sy-uname.
    d_lyt_itcpo-tddest     = d_lyt_tddst.
    d_lyt_itcpo-tdcopies   = d_lyt_nast-anzal.    "abap-hmm 22/03/02
*    PERFORM f_cprog(zabpxop_exec) USING tnapr-pgnam.
  ENDIF.

  d_lyt_error = c_lyt_no.
  CALL FUNCTION 'OPEN_FORM'
       EXPORTING
            device                      = 'PRINTER'
            dialog                      = ' '
            form                        = ld_lyt_fonam
*           LANGUAGE                    = SY-LANGU
            options                     = d_lyt_itcpo
*           MAIL_SENDER                 =
*           MAIL_RECIPIENT              =
*           MAIL_APPL_OBJECT            =
*           RAW_DATA_INTERFACE          = '*'
       IMPORTING
*           LANGUAGE                    =
*           NEW_ARCHIVE_PARAMS          =
            result                      = d_lyt_itcpp
       EXCEPTIONS
            canceled                    = 1
            device                      = 2
            form                        = 3
            options                     = 4
            unclosed                    = 5
            mail_options                = 6
            archive_error               = 7
            invalid_fax_number          = 8
            more_params_needed_in_batch = 9
            OTHERS                      = 10.
  PERFORM f_lyt_check_error.
ENDFORM.                    " F_OPEN_FORM

*&---------------------------------------------------------------------*
*&       FORM F_LYT_WRITE_FORM                                         *
*&---------------------------------------------------------------------*
*& @FU_ELMNT: Window element
*& @FU_WINDW: Window name
*&---------------------------------------------------------------------*
FORM f_lyt_write_form USING fu_elmnt fu_windw.
  DATA: ld_elmnt(30).

  CHECK d_lyt_error EQ c_lyt_no.
  ld_elmnt = fu_elmnt.
  IF fu_elmnt EQ space AND fu_windw NE 'MAIN'.
    ld_elmnt = fu_windw.
  ENDIF.

  d_lyt_error = c_lyt_no.
  CALL FUNCTION 'WRITE_FORM'
       EXPORTING
            element                  = ld_elmnt
            function                 = 'SET'
            type                     = d_lyt_wtype
            window                   = fu_windw
       IMPORTING
            pending_lines            = d_lyt_pline
       EXCEPTIONS
            element                  = 1
            function                 = 2
            type                     = 3
            unopened                 = 4
            unstarted                = 5
            window                   = 6
            bad_pageformat_for_print = 7
            OTHERS                   = 8.
  PERFORM f_lyt_check_error.
ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM F_LYT_CONTROL_FORM                                        *
*&---------------------------------------------------------------------*
FORM f_lyt_control_form USING fu_comnd.
  CHECK d_lyt_error EQ c_lyt_no.
  CALL FUNCTION 'CONTROL_FORM'
       EXPORTING
            command   = fu_comnd
       EXCEPTIONS
            unopened  = 1
            unstarted = 2
            OTHERS    = 3.
  PERFORM f_lyt_check_error.
ENDFORM.         "F_LYT_CONTROL_FORM

*&---------------------------------------------------------------------*
*&      FORM F_LYT_CLOSE_FORM                                          *
*&---------------------------------------------------------------------*
FORM f_lyt_close_form.
  CHECK d_lyt_error EQ c_lyt_no.
  CALL FUNCTION 'CLOSE_FORM'
       IMPORTING
            result   = d_lyt_itcpp  " Information can be useful
       EXCEPTIONS  " eg dest, spool nr etc
            unopened = 1.
  PERFORM f_lyt_check_error.
ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM F_LYT_END_FORM                                            *
*&---------------------------------------------------------------------*
FORM f_lyt_end_form.
  CHECK d_lyt_error EQ c_lyt_no.
  CALL FUNCTION 'END_FORM'
       IMPORTING
            result                   = d_lyt_itcpp
       EXCEPTIONS
            unopened                 = 1
            bad_pageformat_for_print = 2
            OTHERS                   = 3.
  PERFORM f_lyt_check_error.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LYT_PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
FORM f_lyt_protocol_update.
  DATA: ld_objid LIKE tcmf5-object_id.

  CALL FUNCTION 'CM_F_GET_OBJECT'
       IMPORTING
*          OBJECT  =
*          SUBOBJ  =
            objid   = ld_objid.
  CHECK ld_objid NE space.

  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
       EXPORTING
            msg_arbgb = syst-msgid
            msg_nr    = syst-msgno
            msg_ty    = syst-msgty
            msg_v1    = syst-msgv1
            msg_v2    = syst-msgv2
            msg_v3    = syst-msgv3
            msg_v4    = syst-msgv4
       EXCEPTIONS
            OTHERS    = 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LYT_REPRINT_AUTHORITY
*&---------------------------------------------------------------------*
FORM f_lyt_reprint_authority USING fu_objcd.
*  DATA: "ld_athrz LIKE zabpxdt_formotrz,
*        ld_objcd LIKE zpygxdt_obidflnr-objcode.
*
*  d_lyt_error = c_lyt_no.
** Check Object Code for FORM
*  SELECT SINGLE objcode FROM zpygxdt_obidflnr
*    INTO ld_objcd
*   WHERE objcode EQ fu_objcd.
*  IF sy-subrc EQ 0.
**-- Check Authority for REPRINT
*    SELECT SINGLE * FROM zabpxdt_formotrz
*      INTO ld_athrz
*     WHERE uname EQ sy-uname
*       AND stype EQ '+'
*       AND ( objcd EQ fu_objcd OR objcd EQ '*' ).
*    IF sy-subrc EQ 0.
**---- Check if there is any UnAuthority for REPRINT
*      SELECT SINGLE * FROM zabpxdt_formotrz
*        INTO ld_athrz
*       WHERE uname EQ sy-uname
*         AND stype EQ '-'
*         AND objcd EQ fu_objcd.
*      IF sy-subrc EQ 0.
*        sy-msgid = 'ZABP'.
*        sy-msgno = '005'.
*        sy-msgty = 'E'.
*        d_lyt_error = c_lyt_yes.
*        PERFORM f_lyt_protocol_update.
*      ENDIF.
*    ELSE.
*      sy-msgid = 'ZABP'.
*      sy-msgno = '005'.
*      sy-msgty = 'E'.
*      d_lyt_error = c_lyt_yes.
*      PERFORM f_lyt_protocol_update.
*    ENDIF.
*  ELSE.
*    sy-msgid = 'ZABP'.
*    sy-msgno = '006'.
*    sy-msgty = 'E'.
*    d_lyt_error = c_lyt_yes.
*    PERFORM f_lyt_protocol_update.
*  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LYT_GET_FILLING_NUMBER
*&---------------------------------------------------------------------*
FORM f_lyt_get_filling_number USING fu_gsber fu_objid fu_table fu_datum
                                    fu_key01 fu_key02 fu_key03 fu_key04
                                    fu_dsply.
*  DATA: ld_gsber LIKE tgsb-gsber,
*        ld_objid LIKE zpygxdt_obidflnr-objid,
*        ld_table LIKE zpygxdt_obidflnr-tabname,
*        ld_datum LIKE sy-datum,
*        ld_key01 LIKE zpygxdt_nastflnr-key1,
*        ld_key02 LIKE zpygxdt_nastflnr-key2,
*        ld_key03 LIKE zpygxdt_nastflnr-key3,
*        ld_key04 LIKE zpygxdt_nastflnr-key4,
*        ld_dsply TYPE char1.
*
*  d_lyt_error = c_lyt_no.
*  ld_gsber = fu_gsber.
*  ld_objid = fu_objid.
*  ld_table = fu_table.
*  ld_datum = fu_datum.
*  ld_key01 = fu_key01.
*  ld_key02 = fu_key02.
*  ld_key03 = fu_key03.
*  ld_key04 = fu_key04.
*  ld_dsply = fu_dsply.
*
*  CALL FUNCTION 'ZPYGXFC_GET_FILENR'
*       EXPORTING
*            fi_object                  = d_lyt_objct
*            fi_gsber                   = ld_gsber
*            fi_objid                   = ld_objid
*            fi_tabname                 = ld_table
*            fi_datum                   = ld_datum
*            fi_key1                    = ld_key01
*            fi_key2                    = ld_key02
*            fi_key3                    = ld_key03
*            fi_key4                    = ld_key04
*            fi_display                 = ld_dsply
*       IMPORTING
*            fe_flnr                    = d_lyt_flnum
*            fe_counter                 = d_lyt_count
*            fe_firstdatum              = d_lyt_begda
*            fe_firstuzeit              = d_lyt_begtm
*            fe_datum                   = d_lyt_datum
*            fe_uzeit                   = d_lyt_uzeit
*       EXCEPTIONS
*            id_not_found               = 1
*            obj_not_found              = 2
*            get_number_failed          = 3
*            insert_failed              = 4
*            not_authorized_for_print   = 5
*            not_authorized_for_reprint = 6
*            OTHERS                     = 7.
*
*  PERFORM f_lyt_check_error.
ENDFORM.                    " F_LYT_GET_FILLING_NUMBER


* Macro ini bertujuan untuk melakukan pengelompokkan data, dimana data
* dalam satu kelompok yang sama tidak diperbolehkan untuk dicetak di
* dua halaman yang terpisah.
* Syarat untuk menggunakan  macro ini adalah harus terdapat field PGWIN
* dan PAGES pada internal table yang akan di cetak.
* => PGWIN like RSSCF-TDELINE.
DEFINE macro_lyt_determine_which_page.
  data: begin of lt_lyt_pages occurs 0,
         begrw type i,
         endrw type i,
         pages type i,
         lines type i,
        end of lt_lyt_pages.
  data: ld_maxln type i,
        ld_maxcn type i,
        ld_1stdt type i,  "flag for just first data in 1 page
        ld_pgwin like rsscf-tdeline.

  clear: &1-pgwin, &1-pages.
  modify &1 transporting pgwin pages where pgwin ne space.
  describe table &1 lines d_lyt_tfill.
  if d_lyt_tfill le d_lyt_maxln_one.
* Untuk jumlah baris cukup untuk satu halaman saja.
    &1-pgwin = d_lyt_pgwin_one.
    d_lyt_maxpg = &1-pages = 1.
    modify &1 transporting pgwin pages
     where pgwin ne d_lyt_pgwin_one.
  else.
* Untuk jumlah baris yang lebih dari satu halaman.
    lt_lyt_pages-lines = 0.
    loop at &1.
      d_lyt_tabix = sy-tabix.
      at new &2.
* Ambil baris pertama untuk item yang ingin dikelompokkan
        lt_lyt_pages-begrw = d_lyt_tabix.
      endat.
* Hitung jumlah baris
      add 1 to lt_lyt_pages-lines.
* Terkadang dalam kondisi khusus total jumlah baris yang ingin di
* kelompokkan jauh lebih besar dibandingkan maximum baris yang diterima
* halaman tersebut. Untuk kondisi ini perlu dibagi menjadi dua bagian
* sehingga terhindar dari pencetakan data kosong pada halaman yang
* bersangkutan.

      if lt_lyt_pages-lines gt d_lyt_maxln_two.
        subtract 1 from lt_lyt_pages-lines.
        lt_lyt_pages-endrw = d_lyt_tabix - 1.
        append lt_lyt_pages.
        clear lt_lyt_pages.
        add 1 to lt_lyt_pages-lines.
        lt_lyt_pages-begrw = d_lyt_tabix.
      endif.
      at end of &2.
* Ambil baris terakhir untuk item yang ingin dikelompokkan
        lt_lyt_pages-endrw = d_lyt_tabix.
        append lt_lyt_pages.
        clear lt_lyt_pages.
      endat.
    endloop.

* Set nilai maximum baris untuk halaman pertama
    ld_maxln = d_lyt_maxln_two.
    d_lyt_maxpg = 1.
    loop at lt_lyt_pages.
* Jumlahkan total baris yang ada pada tiap uniq data.
      add lt_lyt_pages-lines to ld_maxcn.
      if ld_maxcn gt ld_maxln.
* Jumlah Baris > dari maksimum baris => tambahkan nomor halaman
        add 1 to d_lyt_maxpg.
* Akumulasi total baris halaman pertama dengan halaman berikutnya
* (NEXT)
        add d_lyt_maxln_next to ld_maxln.
      endif.
      lt_lyt_pages-pages = d_lyt_maxpg.
      modify lt_lyt_pages index sy-tabix transporting pages.
    endloop.

* Untuk halaman terakhir, lakukan perhitungan sekali lagi, apakah total
* baris yang tersisa mencukupi untuk diletakkan pada halaman terakhir ?
* Jika tidak mencukupi, buat satu halaman baru lagi.
    ld_maxln = d_lyt_maxln_last.
    ld_maxcn = 0.
    loop at lt_lyt_pages where pages = d_lyt_maxpg.
      add lt_lyt_pages-lines to ld_maxcn.
      if ld_maxcn gt ld_maxln.
        add 1 to d_lyt_maxpg.
        add d_lyt_maxln_last to ld_maxln.
      endif.
      lt_lyt_pages-pages = d_lyt_maxpg.
      modify lt_lyt_pages index sy-tabix transporting pages.
    endloop.

* Berdasarkan jumlah halaman, tentukan jenis halaman yang akan dicetak.
    loop at lt_lyt_pages.
      d_lyt_maxpg = lt_lyt_pages-pages.
      case lt_lyt_pages-pages.
        when 1. ld_pgwin = d_lyt_pgwin_two.
        when d_lyt_maxpg. ld_pgwin = d_lyt_pgwin_last.
        when others. ld_pgwin = d_lyt_pgwin_next.
      endcase.

      loop at &1 from lt_lyt_pages-begrw to lt_lyt_pages-endrw.
        &1-pages = d_lyt_maxpg.
        &1-pgwin = ld_pgwin.
        modify &1 index sy-tabix transporting pgwin pages.
      endloop.
    endloop.
  endif.
END-OF-DEFINITION.
