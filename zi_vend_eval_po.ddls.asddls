@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Evaluation - PO Dataset'
define view entity ZI_VEND_EVAL_PO
  as select from I_PurchaseOrderAPI01 as Header
    inner join I_PurchaseOrderItemAPI01 as Item
      on Item.PurchaseOrder = Header.PurchaseOrder
    left outer join I_PurchaseOrderScheduleLineAPI01 as Schedule
      on  Schedule.PurchaseOrder     = Item.PurchaseOrder
      and Schedule.PurchaseOrderItem = Item.PurchaseOrderItem
{
  key Header.PurchaseOrder,
  key Item.PurchaseOrderItem,
  key Schedule.ScheduleLine,
      Header.CompanyCode,
      Header.Supplier,
      Header.PurchaseOrderDate,
      Header.DocumentCurrency,
      Header.PurchasingOrganization,
      Header.PurchasingGroup,
      Header.PurchaseOrderType,
      Item.Material,
      Item.Plant,
      Item.OrderQuantity,
      Item.PurchaseOrderQuantityUnit,
      Item.NetAmount,
      Schedule.ScheduleLineDeliveryDate
}
