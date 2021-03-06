<%@ page import="org.pih.warehouse.requisition.RequisitionStatus" %>
<div class="action-menu">
	<button name="actionButtonDropDown" class="action-btn" id="requisitionItem-${requisitionItem?.id }-action">
		<img src="${resource(dir: 'images/icons/silk', file: 'bullet_arrow_down.png')}" style="vertical-align: middle"/>
	</button>
	<div class="actions">

        <g:if test="${actionName == 'pick'}">
            <div class="box" style="max-width: 600px;">
                <g:set var="inventoryItemMap" value="${requisitionItem?.retrievePicklistItems()?.groupBy { it?.inventoryItem }}"/>
                <g:form controller="requisition" action="addToPicklistItems">
                    <g:hiddenField name="requisition.id" value="${requisition?.id}"/>
                    <g:hiddenField name="requisitionItem.id" value="${requisitionItem?.id}"/>
                    <h2>
                        ${warehouse.message(code:'picklist.pickingItemsFor.label', default:'Picking items for')}
                        ${requisitionItem?.product?.productCode}
                        ${requisitionItem?.product?.name}

                        <g:if test="${requisitionItem?.productPackage}">
                            (${requisitionItem?.quantity} ${requisitionItem?.productPackage?.uom?.code}/${requisitionItem?.productPackage?.quantity})
                        </g:if>
                        <g:else>
                            (${requisitionItem?.quantity} EA)
                        </g:else>
                        <span class="fade">
                            ${picklistItem?.inventoryItem?.product?.getInventoryLevel(session?.warehouse?.id)?.binLocation}
                        </span>


                    </h2>
                    <table>

                        <thead>
                            <tr>
                                <th colspan="3" class="center no-border-bottom border-right">
                                    ${warehouse.message(code: 'inventory.availableItems.label', default: 'Available items')}
                                </th>
                                <th colspan="4" class="center no-border-bottom">
                                    ${warehouse.message(code: 'picklist.picklistItems.label')}
                                </th>
                            </tr>
                            <tr>
                                <th>
                                    ${warehouse.message(code: 'inventoryItem.lotNumber.label')}
                                </th>
                                <th>
                                    ${warehouse.message(code: 'inventoryItem.expirationDate.label')}
                                </th>
                                <th class="center border-right">
                                    ${warehouse.message(code: 'requisitionItem.quantityAvailable.label')}
                                </th>
                                <%--
                                <th>
                                    ${warehouse.message(code: 'requisitionItem.quantityToPick.label', default:'Quantity to pick')}
                                </th>
                                --%>
                                <th class="center">
                                    ${warehouse.message(code: 'picklistItem.quantity.label')}
                                </th>
                                <th class="center">
                                    ${warehouse.message(code: 'product.uom.label')}
                                </th>
                                <th>
                                    ${warehouse.message(code: 'default.actions.label')}
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <g:set var="inventoryItems" value="${productInventoryItemsMap[requisitionItem?.product?.id]?.findAll { it.quantity > 0 }}"/>
                            <g:unless test="${inventoryItems}">
                                <tr style="height: 60px;">
                                    <td colspan="7" class="center middle">
                                        <span class="fade">${warehouse.message(code: 'requisitionItem.noInventoryItems.label', default: 'No available items')}</span>
                                    </td>
                                </tr>
                            </g:unless>
                            <g:each var="inventoryItem" in="${inventoryItems}" status="status">
                                <g:set var="picklistItem" value="${inventoryItemMap[inventoryItem]?.first()}"/>
                                <g:set var="quantityPicked" value="${inventoryItemMap[inventoryItem]?.first()?.quantity ?: 0}"/>
                                <g:set var="quantityRemaining" value="${requisitionItem?.calculateQuantityRemaining()?: 0}"/>
                                <tr class="prop ${status % 2 ? 'odd' : 'even'}">
                                    <td class="middle">
                                        <span class="lotNumber">${inventoryItem?.lotNumber?:warehouse.message(code:'default.none.label')}</span>
                                    </td>
                                    <td class="middle">
                                        <g:if test="${inventoryItem?.expirationDate}">
                                            <g:formatDate
                                                    date="${inventoryItem?.expirationDate}"
                                                    format="MMM yyyy"/>
                                        </g:if>
                                        <g:else>
                                            <span class="fade"><warehouse:message code="default.never.label"/></span>
                                        </g:else>
                                    </td>
                                    <td class="middle center border-right">
                                        ${inventoryItem?.quantity ?: 0}
                                        ${inventoryItem?.product?.unitOfMeasure?:"EA"}
                                    </td>
                                    <%--
                                    <td>
                                        <g:link controller="requisition" action="addToPicklistItems" id="${requisition?.id}" params=""
                                            class="button icon arrowright" >
                                            ${requisitionItem?.calculateQuantityRemaining()} ${inventoryItem?.product?.unitOfMeasure?:"EA"}
                                        </g:link>
                                    </td>
                                    --%>
                                    <td class="middle center">
                                        <g:hiddenField name="picklistItems[${status}].id" value="${picklistItem?.id}"/>
                                        <g:hiddenField name="picklistItems[${status}].requisitionItem.id" value="${picklistItem?.requisitionItem?.id?:requisitionItem?.id}"/>
                                        <g:hiddenField name="picklistItems[${status}].inventoryItem.id" value="${picklistItem?.inventoryItem?.id?:inventoryItem?.id}"/>
                                        <input name="picklistItems[${status}].quantity" value="${quantityPicked}" size="5" type="text" class="text"/>
                                    </td>
                                    <td class="middle center">
                                        ${inventoryItem?.product?.unitOfMeasure ?: "EA"}
                                    </td>
                                    <td>
                                        <g:if test="${picklistItem}">
                                            <g:link controller="picklistItem"
                                                    action="delete"
                                                    id="${picklistItem?.id}"
                                                    class="button icon remove"
                                                    onclick="return confirm('${warehouse.message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');">
                                                <warehouse:message code="picklist.removeFromPicklistItems.label" default="Remove from picklist"/>
                                            </g:link>
                                        </g:if>
                                    </td>
                                </tr>

                            </g:each>
                        </tbody>
                        <g:if test="${inventoryItems}">
                            <tfoot>
                                <tr>
                                    <td colspan="7" class="center">
                                        <g:if test="${requisitionItem?.retrievePicklistItems()}">
                                            <button class="button">
                                                ${warehouse.message(code: 'picklist.updatePicklistItems.label', default:'Update picklist items')}
                                            </button>
                                        </g:if>
                                        <g:else>
                                            <button class="button">
                                                ${warehouse.message(code: 'picklist.addToPicklistItems.label', default:'Add to picklist items')}
                                            </button>

                                        </g:else>
                                    </td>
                                </tr>
                            </tfoot>
                        </g:if>
                    </table>
                </g:form>

            </div>
        </g:if>
        <%-- requisitionItem?.requisition?.status == RequisitionStatus.REVIEWING --%>
        <g:elseif test="${actionName == 'review' }">

            <%--
            <div class="action-menu-item">
                <g:link controller="requisition" action="review" id="${requisition?.id }" params="['requisitionItem.id':requisitionItem?.id]">
                    <img src="${resource(dir: 'images/icons/silk', file: 'pencil.png')}"/>&nbsp;
                    <warehouse:message code="default.button.review.label"/>
                </g:link>
            </div>
            <div class="action-menu-item">
                <g:link controller="requisitionItem" action="approveQuantity" id="${requisitionItem?.requisition?.id }"
                        params="['requisitionItem.id':requisitionItem?.id]">
                    <img src="${resource(dir: 'images/icons/silk', file: 'tick.png')}"/>&nbsp;
                    <warehouse:message code="requisitionItem.approveQuantity.label" default="Approve quantity"/>
                </g:link>
            </div>
            --%>
            <g:if test="${requisitionItem?.canApproveQuantity()}">
                <div class="action-menu-item">
                    <g:link controller="requisitionItem" action="approveQuantity" id="${requisitionItem?.id }" fragment="${requisitionItem?.id}">
                        <img src="${resource(dir: 'images/icons/silk', file: 'accept.png')}"/>&nbsp;
                        <warehouse:message code="requisitionItem.approveQuantity.label" default="Approve quantity"/>
                    </g:link>
                </div>
            </g:if>
            <g:if test="${requisitionItem.canChangeQuantity()}">
                <div class="action-menu-item">
                    <g:link controller="requisition" action="review" id="${requisitionItem?.requisition?.id }"
                            params="['requisitionItem.id':requisitionItem?.id, actionType:'changeQuantity']" fragment="${requisitionItem?.id}">
                        <img src="${resource(dir: 'images/icons/silk', file: 'pencil.png')}"/>&nbsp;
                        <warehouse:message code="requisitionItem.changeQuantity.label" default="Change quantity"/>
                    </g:link>
                </div>
            </g:if>
                <%--
                <div class="action-menu-item">
                    <g:link controller="requisition" action="review" id="${requisitionItem?.requisition?.id }"
                            params="['requisitionItem.id':requisitionItem?.id, actionType:'changePackageSize']">
                        <img src="${resource(dir: 'images/icons/silk', file: 'pencil.png')}"/>&nbsp;
                        <warehouse:message code="requisitionItem.changePackageSize.label" default="Change package size"/>
                    </g:link>
                </div>
                --%>
            <g:if test="${requisitionItem.canChooseSubstitute()}">
                <div class="action-menu-item">
                    <g:link controller="requisition" action="review" id="${requisitionItem?.requisition?.id }" fragment="${requisitionItem?.id}"
                            params="['requisitionItem.id':requisitionItem?.id, actionType:'chooseSubstitute']" >
                        <img src="${resource(dir: 'images/icons/silk', file: 'arrow_switch.png')}"/>&nbsp;
                        <warehouse:message code="requisitionItem.substitute.label" default="Choose substitute"/>
                    </g:link>
                </div>
            </g:if>
            <g:if test="${requisitionItem.canChangeQuantity()}">
                <div class="action-menu-item">
                    <g:link controller="requisition" action="review" id="${requisitionItem?.requisition?.id }"
                            params="['requisitionItem.id':requisitionItem?.id, actionType:'cancelQuantity']" fragment="${requisitionItem?.id}">
                        <img src="${resource(dir: 'images/icons/silk', file: 'decline.png')}"/>&nbsp;
                        <warehouse:message code="requisitionItem.cancel.label" default="Cancel requisition item"/>
                    </g:link>
                </div>
            </g:if>
            <g:if test="${requisitionItem.canUndoChanges()}">
                <div class="action-menu-item">
                    <g:link controller="requisitionItem" action="undoChanges" id="${requisitionItem?.id }" params="[redirectAction:'review']" fragment="${requisitionItem?.id}"
                            onclick="return confirm('${warehouse.message(code: 'default.button.undo.confirm.message', default: 'Are you sure?')}');">
                        <img src="${resource(dir: 'images/icons/silk', file: 'arrow_undo.png')}"/>&nbsp;
                        <warehouse:message code="requisitionItem.undoChange.label" default="Undo changes"/>
                    </g:link>
                </div>
            </g:if>
            <%--
            <div class="action-menu-item">
                <g:link controller="requisition" action="review" id="${requisitionItem?.requisition?.id }"
                        params="['requisitionItem.id':requisitionItem?.id, actionType:'supplementProduct']">
                    <img src="${resource(dir: 'images/icons/silk', file: 'add.png')}"/>&nbsp;
                    <warehouse:message code="requisitionItem.supplement.label" default="Supplement with different product"/>
                </g:link>
            </div>
            --%>
            <g:isUserAdmin>
                <div class="action-menu-item">
                    <hr/>
                </div>
                <div class="action-menu-item">
                    <g:link controller="requisitionItem" action="delete" id="${requisitionItem?.id }" fragment="${requisitionItem?.id}"
                            onclick="return confirm('${warehouse.message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');">
                        <img src="${resource(dir: 'images/icons/silk', file: 'delete.png')}"/>&nbsp;
                        <warehouse:message code="requisitionItem.delete.label"/>
                    </g:link>
                </div>
            </g:isUserAdmin>
        </g:elseif>
        <%--
		<div class="action-menu-item">
			<g:link controller="requisitionItem" action="change">
				<img src="${resource(dir: 'images/icons/silk', file: 'box.png')}"/>&nbsp;
				<warehouse:message code="requisitionItem.pick.label"/>
			</g:link>
		</div>
		<div class="action-menu-item">
			<g:link controller="requisitionItem" action="substitute">
				<img src="${resource(dir: 'images/icons/silk', file: 'box.png')}"/>&nbsp;
				<warehouse:message code="requisitionItem.substitute.label"/>
			</g:link>
		</div>
		<div class="action-menu-item">
			<g:link controller="requisitionItem" action="cancel">
				<img src="${resource(dir: 'images/icons/silk', file: 'cross.png')}"/>&nbsp;
				<warehouse:message code="requisitionItem.cancel.label"/>
			</g:link>
		</div>
		<div class="action-menu-item">
			<hr/>
		</div>
		--%>
        <%--
        <g:link controller="requisition" action="review" id="${requisition?.id }" params="['requisitionItem.id':requisitionItem?.id]" class="button">
            <warehouse:message code="default.button.change.label"/>
        </g:link>
        <g:link controller="requisitionItem" action="change" id="${requisitionItem?.id }" class="button">
            <warehouse:message code="default.button.change.label"/>
        </g:link>
        <g:link controller="requisitionItem" action="delete" id="${requisitionItem?.id }" class="button"
                onclick="return confirm('${warehouse.message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');">
            <warehouse:message code="default.button.delete.label"/>
        </g:link>
        <g:link controller="requisitionItem" action="undoCancel" id="${requisitionItem?.id }" class="button"
                onclick="return confirm('${warehouse.message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');">
            <warehouse:message code="default.button.undoCancel.label"/>
        </g:link>
        --%>


	</div>
</div>	

