FUNCTION z_gdtxfc_tax_cfg_org_detmn.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FI_BRNCH) TYPE  ZGDTXDE_BRNCH OPTIONAL
*"     VALUE(FI_BUSLN) TYPE  ZGDTXDE_BUSLN OPTIONAL
*"     VALUE(FI_BUKRS) TYPE  BUKRS OPTIONAL
*"  EXPORTING
*"     VALUE(FE_BUKRS) TYPE  BUKRS
*"     VALUE(FE_BUSDS) TYPE  ZGDTXDE_BUSDS
*"     VALUE(FE_BDESC) TYPE  ZGDTXDE_BDESC
*"     VALUE(FE_HO_IND) TYPE  ZGDTXDE_HOIND
*"     VALUE(FE_HOLD) TYPE  ZGDTXDE_HCOMPANY
*"  TABLES
*"      FT_TX00101 STRUCTURE  ZGDTXDT0101
*"      FT_TX00102 STRUCTURE  ZGDTXDT0102
*"      FT_TX00103 STRUCTURE  ZGDTXDT0103
*"  EXCEPTIONS
*"      COMPANY_CODE_NOT_ASSIGNED
*"      BUSINESS_LINE_NOT_MAINTAINED
*"      BRANCH_CONFIG_NOT_MAINTAINED
*"      BUSLINE_CONFIG_NOT_MAINTAINED
*"      TAXCONSOL_CONFIG_NOT_MAINTAIN
*"----------------------------------------------------------------------

**Get Config tables values
  SELECT * INTO TABLE ft_tx00101 FROM zgdtxdt0101.
  IF sy-subrc = 0.
    SORT ft_tx00101 BY brnch bukrs.
  ELSE.
    MESSAGE e000(zab) WITH 'Branch Config table is not maintained'
                      RAISING branch_config_not_maintained.
  ENDIF.

  SELECT * INTO TABLE ft_tx00102 FROM zgdtxdt0102.
  IF sy-subrc = 0.
    SORT ft_tx00102 BY busln.
  ELSE.
    MESSAGE e000(zab) WITH 'Business Line Config table'
                           'is not maintained'
                      RAISING busline_config_not_maintained.
  ENDIF.

  SELECT * INTO TABLE ft_tx00103 FROM zgdtxdt0103.
  IF sy-subrc = 0.
    SORT ft_tx00103 BY brnch busln.
  ELSE.
    MESSAGE e000(zab) WITH 'Tax Consolidation Config table'
                           'is not maintained'
                      RAISING taxconsol_config_not_maintain.
  ENDIF.

**Get Company code & Branch description
  IF NOT fi_brnch IS INITIAL AND
     NOT fi_bukrs IS INITIAL.
    READ TABLE ft_tx00101 WITH KEY brnch = fi_brnch
                                   bukrs = fi_bukrs
                          BINARY SEARCH.
    IF sy-subrc <> 0.
      MESSAGE e000(zab) WITH 'No Company code assigned for the branch'
                          RAISING company_code_not_assigned.
    ENDIF.
    fe_bdesc = ft_tx00101-bdesc.
    fe_ho_ind = ft_tx00101-ho_ind.
    fe_hold = ft_tx00101-hcompany.
  ENDIF.

  IF NOT fi_brnch IS INITIAL AND
     fi_bukrs IS INITIAL.
    READ TABLE ft_tx00101 WITH KEY brnch = fi_brnch
                          BINARY SEARCH.
    IF sy-subrc <> 0.
      MESSAGE e000(zab) WITH 'No Company code assigned for the branch'
                          RAISING company_code_not_assigned.
    ENDIF.
    fe_bukrs = ft_tx00101-bukrs.
    fe_bdesc = ft_tx00101-bdesc.
    fe_hold = ft_tx00101-hcompany.
  ENDIF.

  IF fi_brnch IS INITIAL AND
     NOT fi_bukrs IS INITIAL.
    READ TABLE ft_tx00101 WITH KEY bukrs = fi_bukrs.
    IF sy-subrc <> 0.
      MESSAGE e000(zab) WITH 'No Company code assigned for the branch'
                          RAISING company_code_not_assigned.
    ENDIF.
    fe_bukrs = ft_tx00101-bukrs.
    fe_bdesc = ft_tx00101-bdesc.
    fe_hold = ft_tx00101-hcompany.
  ENDIF.

**Get Business Line Description
  IF NOT fi_busln IS INITIAL.
    READ TABLE ft_tx00102 WITH KEY busln = fi_busln
                          BINARY SEARCH.
    IF sy-subrc = 0.
      fe_busds = ft_tx00102-busds.
    ELSE.
      MESSAGE e000(zab) WITH 'Business Line is not maintained'
                        RAISING business_line_not_maintained.
    ENDIF.
  ENDIF.

ENDFUNCTION.
