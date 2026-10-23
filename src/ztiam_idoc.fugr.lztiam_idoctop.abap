FUNCTION-POOL ztiam_idoc.                   "MESSAGE-ID ..

TABLES: nast, ztiamitdt001, ztiamitdt002, edidc.
*----------------------------------------------------------------------*
* C O N S T A N T S
*----------------------------------------------------------------------*
CONSTANTS:
      c_sndprt LIKE edidc-sndprt VALUE 'LS',          "Destination System
      c_credit TYPE shkzg VALUE 'H',
      c_idoctyp_imm02   TYPE edi_iapi00-idoctyp VALUE 'ZMBGMCR', "DEVK934346
      c_idoctyp_inv02   TYPE edi_iapi00-idoctyp VALUE 'INVOIC02',
      c_mestyp_inv02    TYPE edi_iapi00-idoctyp VALUE 'INVOIC',
      c_mestyp_imm02    TYPE edi_iapi00-idoctyp VALUE 'ZMBGMCR1'. "DEVK934346

TYPES:       BEGIN OF ty_line,
          v_text(1500)        TYPE c,
      END OF ty_line.
TYPES: BEGIN OF t_mkpf,
          mblnr LIKE mkpf-mblnr,
          mjahr LIKE mkpf-mjahr,
          bldat LIKE mkpf-bldat,
          budat LIKE mkpf-budat,
          aedat LIKE mkpf-aedat,
          usnam LIKE mkpf-usnam,
          xblnr LIKE mkpf-xblnr,
          bktxt LIKE mkpf-bktxt,
       END OF t_mkpf.

TYPES: BEGIN OF t_mseg,
          mblnr LIKE mseg-mblnr,
          mjahr LIKE mseg-mjahr,
          zeile LIKE mseg-zeile,
          bwart LIKE mseg-bwart,
          werks LIKE mseg-werks,
          lgort LIKE mseg-lgort,
          erfmg LIKE mseg-erfmg,
          erfme LIKE mseg-erfme,
          ebeln LIKE mseg-ebeln,
          ebelp LIKE mseg-ebelp,
          pargb LIKE mseg-pargb,
          anln1 LIKE mseg-anln1,
          anln2 LIKE mseg-anln2,
          sgtxt LIKE mseg-sgtxt,
          lfbnr LIKE mseg-lfbnr,
          lfpos LIKE mseg-lfpos,
          bukrs LIKE mseg-bukrs,
          ablad LIKE mseg-ablad,
          smbln LIKE mseg-smbln,
          smblp LIKE mseg-smblp,
          sjahr LIKE mseg-sjahr,
       END OF t_mseg.

TYPES: BEGIN OF t_ekbe,
        ebeln LIKE ekbe-ebeln,
        ebelp LIKE ekbe-ebelp,
        gjahr LIKE ekbe-gjahr,
        belnr LIKE ekbe-belnr,
        buzei LIKE ekbe-buzei,
        bewtp LIKE ekbe-bewtp,
        bwart LIKE ekbe-bwart,
        budat LIKE ekbe-budat,
        menge LIKE ekbe-menge,
        wrbtr LIKE ekbe-wrbtr,
        waers LIKE ekbe-waers,
        elikz LIKE ekbe-elikz,
        werks LIKE ekbe-werks,
        ernam LIKE ekbe-ernam,
        wesbs LIKE ekbe-wesbs,
        lfbnr LIKE ekbe-lfbnr,
        shkzg LIKE ekbe-shkzg,
       END OF t_ekbe.
TYPES: BEGIN OF t_ekkn,
        bukrs LIKE mseg-bukrs,
        anln1 LIKE ekkn-anln1,
        anln2 LIKE ekkn-anln2,
        ebeln LIKE ekkn-ebeln,
        ebelp LIKE ekkn-ebelp,
        zekkn LIKE ekkn-zekkn,
     END OF t_ekkn.

DATA: gt_mseg TYPE t_mseg OCCURS 0 WITH HEADER LINE,
      gt_ekkn TYPE t_ekkn OCCURS 0 WITH HEADER LINE,
      wa_mkpf TYPE t_mkpf,
      gt_ekbe TYPE t_ekbe OCCURS 0 WITH HEADER LINE.
DATA:
       wa_edisdef       TYPE edisdef,
       wa_edidc         TYPE edidc,
       wa_edidd_o       TYPE edidd,
       wa_mgbmcr        TYPE e1mbgmcr,
"       wa_bpparex       TYPE e1bpparex,
"       wa_tabline       TYPE ty_line,
       wa_tabsegment    TYPE ty_line,

       wa_idoctype_hdr  TYPE edi_iapi10,
       wa_segment       TYPE edi_iapi11,

      wa_edidd         TYPE edi_dd40,
       gt_edidc40       TYPE STANDARD TABLE OF edi_dc40, "Idoc Control Record

       gt_edidd         TYPE STANDARD TABLE OF edi_dd40,   "Data Records
       gt_edidd_o       TYPE STANDARD TABLE OF edidd,
       gt_comm_idoc     TYPE STANDARD TABLE OF edidc,   "Generated Communication IDOc
       gt_segment       TYPE STANDARD TABLE OF edi_iapi11.
DATA: gv_rebzg LIKE bseg-rebzg.
DATA: gt_anla TYPE STANDARD TABLE OF anla WITH HEADER LINE.
DATA: gt_anlb TYPE STANDARD TABLE OF anlb WITH HEADER LINE.
DATA: gt_anlc TYPE STANDARD TABLE OF anlc WITH HEADER LINE.

DATA : gs_edi_dc40  LIKE edi_dc40. "Idoc Control Record
DATA : gt_edi_dc40  LIKE edi_dc40 OCCURS 0 WITH HEADER LINE.   "Generated Communication IDOc
DATA : gs_edidd     LIKE edi_dd40.

DATA   : gv_filename(14)  TYPE c.
DATA: gv_docnum LIKE edidd-docnum.
DATA: idoc_message TYPE idoc_msg. "(200).

DATA: wa_zmseg  LIKE zmseg.
DATA: wa_zmkpf  LIKE zmkpf.
DATA: wa_zekbe  LIKE zekbe.
DATA: wa_zanla  LIKE zanla.
DATA: wa_zanlb  LIKE zanlb.
DATA: wa_zanlc  LIKE zanlc.

*** Define for API Get Data PR
TYPES: BEGIN OF t_ebkn,
          banfn  TYPE string,
          bnfpo  TYPE string,
          zebkn  TYPE string,
          menge  TYPE string,
          sakto  TYPE string,
          gsber  TYPE string,
          kostl  TYPE string,
          anln1  TYPE string,
          anln2  TYPE string,
          aufnr  TYPE string,
          zbukrs  TYPE string,
          zbanfn  TYPE string,
          ablad  TYPE string,
          zabladno  TYPE string,
          kokrs  TYPE string,
          ernam  TYPE string,
          erdat  TYPE string,
          aenam  TYPE string,
          aedat  TYPE string,
  END OF t_ebkn.

TYPES: BEGIN OF t_zeban,
          banfn  TYPE string,
          bnfpo  TYPE string,
          zbukrs  TYPE string,
          zbanfn  TYPE string,
          urut   TYPE string,
          txt  TYPE string,
  END OF t_zeban.

TYPES: BEGIN OF t_pr,
          banfn  TYPE string,
          bnfpo  TYPE string,
          bsart  TYPE string,
          bstyp  TYPE string,
          loekz  TYPE string,
          ekgrp  TYPE string,
          afnam  TYPE string,
          txz01  TYPE string,
          matnr  TYPE string,
          werks  TYPE string,
          zwerks  TYPE string,
          lgort  TYPE string,
          bednr  TYPE string,
          matkl  TYPE string,
          menge  TYPE string,
          meins  TYPE string,
          badat  TYPE string,
          lfdat  TYPE string,
          preis  TYPE string,
          peinh  TYPE string,
          knttp  TYPE string,
          wepos  TYPE string,
          weunb  TYPE string,
          repos  TYPE string,
          ekorg  TYPE string,
          ebeln  TYPE string,
          ebelp  TYPE string,
          ztext  TYPE string,
          zappr  TYPE string,
          zcancel  TYPE string,
          zbukrs  TYPE string,
          zbanfn  TYPE string,
          ablad  TYPE string,
          zabladno  TYPE string,
          ernam  TYPE string,
          erdat  TYPE string,
          aenam  TYPE string,
          aedat  TYPE string,
          ebkn TYPE STANDARD TABLE OF t_ebkn WITH NON-UNIQUE DEFAULT KEY,
          zeban TYPE STANDARD TABLE OF t_zeban WITH NON-UNIQUE DEFAULT KEY,
  END OF t_pr.

TYPES: BEGIN OF tpr,
          result TYPE  STANDARD TABLE OF t_pr WITH NON-UNIQUE DEFAULT KEY,
      END OF tpr.
DATA: gv_banfn TYPE banfn.
DATA  gs_eban TYPE tpr.
DATA : gv_inputpath LIKE edi_path-pthnam,
      gv_fullfile  LIKE edi_path-pthnam.
DATA: gs_ztiamitdt001  LIKE ztiamitdt001.
DATA: gs_ztiamitdt002  LIKE ztiamitdt002.
"
CONSTANTS:  c_mestyp LIKE edidc-mestyp VALUE 'PREQCR1'. ", "FIXEDASSET_CREATEFROMDATA1',    "FIXEDASSET_CREATE02
CONSTANTS:
      c_idoctp LIKE edidc-idoctp VALUE 'PREQCR101', "FIXEDASSET_CREATEFROMDATA102
      c_rcvprt LIKE edidc-rcvprt VALUE 'LS'.         "Partner type of receiver
"c_sndprt LIKE edidc-sndprt VALUE 'LS'.          "Destination System

"DATA : gt_edi_dc40  LIKE edi_dc40 OCCURS 0 WITH HEADER LINE.  "Generated Communication IDOc
"DATA : gs_edi_dc40  LIKE edi_dc40. "Idoc Control Record
"DATA: "gv_filename(14)  TYPE c,
"       wa_edidd         TYPE edi_dd40,
"       gt_edidd         TYPE STANDARD TABLE OF edi_dd40.   "Data Records
"DATA: c_segnam LIKE edi_dd40-segnam.


DATA: t_e1bpmereqheader TYPE STANDARD TABLE OF e1bpmereqheader WITH HEADER LINE.
DATA: t_e1bpmereqheaderx TYPE STANDARD TABLE OF e1bpmereqheaderx WITH HEADER LINE.

DATA: t_e1bpmereqitem TYPE STANDARD TABLE OF e1bpmereqitem WITH HEADER LINE.
DATA: t_e1bpmereqitemx TYPE STANDARD TABLE OF e1bpmereqitemx WITH HEADER LINE.

DATA: t_e1bpmereqitemimp TYPE STANDARD TABLE OF e1bpmereqitemimp WITH HEADER LINE.

DATA: t_e1bpmereqaccount TYPE STANDARD TABLE OF e1bpmereqaccount WITH HEADER LINE.
DATA: t_e1bpmereqaccountx TYPE STANDARD TABLE OF e1bpmereqaccountx WITH HEADER LINE.

DATA: t_e1bpmereqaccountprofitseg TYPE STANDARD TABLE OF e1bpmereqaccountprofitseg WITH HEADER LINE.

DATA: t_e1bpmereqheadtext TYPE STANDARD TABLE OF e1bpmereqheadtext WITH HEADER LINE.
DATA: t_e1bpmereqitemtext TYPE STANDARD TABLE OF e1bpmereqitemtext WITH HEADER LINE.
DATA: t_e1preqcr1 TYPE STANDARD TABLE OF e1preqcr1 WITH HEADER LINE.
DATA: gv_sw(1).
DATA: c_segnam LIKE edi_dd40-segnam.


** End Define for get data PR TIAM
