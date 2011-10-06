<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="../includes/js_css.jsp" %>
<openmrs:require privilege="View Bills" otherwise="/login.htm" />
<style type="text/css">
.hidden {
	display: none;
}
</style>

<style>
@media print {
	.donotprint {
		display: none;
	}
	.spacer {
		margin-top: 70px;
		font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
		font-style: normal;
		font-size: 14px;
	}
	.printfont {
		font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
		font-style: normal;
		font-size: 14px;
	}
}
</style>

<link type="text/css" rel="stylesheet"
	href="${pageContext.request.contextPath}/moduleResources/billing/styles/paging.css" />
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/billing/scripts/paging.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/jquery-1.4.2.min.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/billing/scripts/common.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/jquery-ui-1.8.2.custom.min.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/jquery.PrintArea.js"></script>

<p>
	<b><a
		href="addPatientServiceBill.form?patientId=${patient.patientId}">Add
			new Bill</a> 
		<c:if test="${freeBill}">
			<span style="color:red">Free Bill</span>
		</c:if>
	</b>
			
</p>
<c:forEach items="${errors}" var="error">
	<span class="error"><spring:message
			code="${error.defaultMessage}" text="${error.defaultMessage}" /> </span>
</c:forEach>
<c:if test="${not empty bill}">
	<div id="billContainer" style="margin: 10px auto; width: 981px;">
		<table>
			<tr>
				<td>Patient ID no:</td>
				<td>${patient.patientIdentifier.identifier}</td>
			</tr>
			<tr>
				<td>Name of the patient:</td>
				<td>${patient.givenName}&nbsp;&nbsp;${patient.middleName}&nbsp;&nbsp;
					${patient.familyName}</td>
			</tr>
			<tr>
				<td>Date:</td>
				<td><openmrs:formatDate date="${bill.createdDate}"
						type="textbox" /></td>
			</tr>
			<tr>
				<td>Bill ID:</td>
				<td>${bill.receipt.id}</td>
			</tr>
		</table>
		<table width="100%" border="1">
			<thead>
				<th>Service Name</th>
				<th>Price (Rs)</th>
				<th>Quantity</th>
				<th>Amount</th>
			</thead>
			<c:forEach items="${bill.billItems}" var="item" varStatus="status">
				<tr>
					<td>${item.name}</td>
					<td align="right">${item.unitPrice}</td>
					<td align="right">${item.quantity}</td>
					<td class="printfont" height="20" align="right" style="">	
						<c:choose>
							<c:when test="${item.actualAmount eq item.amount}">
								${item.amount}
							</c:when>
							<c:otherwise>
								<span style="text-decoration:line-through;">${item.amount}</span>
								<b>${item.actualAmount}</b>								
							</c:otherwise>
						</c:choose>				
													
					</td>
				</tr>
			</c:forEach>
			<tr>
				<td colspan="3">Total</td>
				<td align="right">									
					<c:choose>
							<c:when test="${bill.actualAmount eq bill.amount}">
								${bill.amount}
							</c:when>
							<c:otherwise>
								<span style="text-decoration:line-through;">${bill.amount}</span>
								<b>${bill.actualAmount}</b>								
							</c:otherwise>
						</c:choose>		
				</td>
			</tr>
		</table>
		<br>
		<form method="POST" id="billForm">
			<center>
				<c:if test="${bill.voided==false }">
					<input type="button"
						value='<spring:message code="billing.print" />'
						onClick="printDiv2();" />&nbsp;&nbsp;</c:if>
				<a href="#" onclick="javascript:jQuery('#billContainer').hide();">Hide</a>
			</center>
		</form>
	</div>

	<!-- PRINT DIV -->

	<div id="printDiv" class="hidden"
		style="width: 1280px; font-size: 0.8em">
		<style>
@media print {
	.donotprint {
		display: none;
	}
	.spacer {
		margin-top: 100px;
		font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
		font-style: normal;
		font-size: 14px;
	}
	.printfont {
		font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
		font-style: normal;
		font-size: 14px;
	}
}
</style>
		<input type="hidden" id="contextPath"
			value="${pageContext.request.contextPath}" /> <img
			class="donotprint"
			src="${pageContext.request.contextPath}/moduleResources/billing/HEADEROPDSLIP.jpg"
			width="981" height="212"></img>
		<table class="spacer" style="margin-left: 60px;">
			<tr>
				<td>Patient ID:</td>
				<td colspan="3">${patient.patientIdentifier}</td>
			</tr>
			<tr>
				<td>Name:</td>
				<td colspan="3">${patient.givenName}&nbsp;&nbsp;${patient.middleName}&nbsp;&nbsp;
					${patient.familyName}</td>
			</tr>
			<tr>
				<td>Date:</td>
				<td align="left"><openmrs:formatDate date="${bill.createdDate}"
						type="textbox" /></td>
			</tr>
			<tr>
				<td>Bill ID:</td>
				<td>${bill.receipt.id}</td>
			</tr>
		</table>
		<table class="printfont"
			style="margin-left: 60px; margin-top: 10px; font-family: 'Dot Matrix Normal', Arial, Helvetica, sans-serif; font-style: normal;"
			width="80%">
			<thead>
				<th class="printfont" style="">Service Name</th>
				<th class="printfont" style="">Price (Rs)</th>
				<th class="printfont" style="">Quantity</th>
				<th class="printfont" style="">Amount</th>
			</thead>
			<c:forEach items="${bill.billItems}" var="item" varStatus="status">
				<tr>
					<td class="printfont" height="20" style="">${item.name}</td>
					<td class="printfont" height="20" align="right" style="">${item.unitPrice}</td>
					<td class="printfont" height="20" align="right" style="">${item.quantity}</td>
					<td class="printfont" height="20" align="right" style="">						
						${item.actualAmount}
					</td>
				</tr>
			</c:forEach>
			<tr>
				<td colspan="3">Total</td>
				<td align="right">
					${bill.actualAmount}
				</td>
			</tr>
		</table>
		<br> <span class="printfont" style="margin-left: 60px;">Total
			Amount:</span> Rupees <span id="totalValue2" class="printfont"> </span> only
		<br /> <br /> <br /> <br /> <br /> <br /> <span
			class="printfont" style="margin-left: 200px;">Signature of
			billing clerk/ Stamp</span>
	</div>


</c:if>

<!-- END PRINT DIV -->


<script>
	function printDivNoJQuery() {
		var divToPrint = document.getElementById('printDiv');
		var newWin = window
				.open('', '',
						'letf=0,top=0,width=1,height=1,toolbar=0,scrollbars=0,status=0');
		newWin.document.write(divToPrint.innerHTML);
		newWin.print();
		newWin.close();
		//setTimeout(function(){window.location.href = $("#contextPath").val()+"/getBill.list"}, 1000);	
	}
	function printDiv2() {
		var printer = window.open('', '', 'width=300,height=300');
		printer.document.open("text/html");
		printer.document.write(document.getElementById('printDiv').innerHTML);
		printer.document.close();
		printer.window.close();
		printer.print();
		jQuery("#billForm").submit();
		//alert("Printing ...");
	}
</script>

<c:if test="${not empty listBill}">
	<span class="boxHeader">List bills</span>
	<table class="box">
		<thead>
			<th>#</th>
			<th>Bill Name</th>
			<th>Action</th>
		</thead>
		<c:forEach items="${listBill}" var="bill" varStatus="varStatus">
			<tr
				class='${varStatus.index % 2 == 0 ? "oddRow" : "evenRow" } <c:if test="${bill.voided}">retired </c:if>'>
				<td><c:out
						value="${(( pagingUtil.currentPage - 1  ) * pagingUtil.pageSize ) + varStatus.count }" />
				</td>
				<td><c:choose>
						<c:when
							test="${bill.voided == false && ( bill.printed == false || ( bill.printed == true && canEdit == true ) )}">
							<a
								href="${pageContext.request.contextPath}/module/billing/editPatientServiceBill.form?billId=${bill.patientServiceBillId}&patientId=${patient.patientId}">Bill
								ID <b>${bill.receipt.id}</b>,<openmrs:formatDate
									date="${bill.createdDate }" type="textbox" /> </a>
				</td>
				</c:when>
				<c:otherwise>
						Bill ID <b>${bill.receipt.id}</b>,
						<openmrs:formatDate date="${bill.createdDate }" />
				</c:otherwise>
				</c:choose>
				<td><input type="button" value="View"
					onclick="javascript:window.location.href='patientServiceBill.list?patientId=${patient.patientId}&billId=${bill.patientServiceBillId}'" />
				</td>
			</tr>
		</c:forEach>
		<tr class="paging-container">
			<td colspan="3"><%@ include file="../paging.jsp"%></td>
		</tr>
	</table>
</c:if>

<input type="hidden" id="total"
	value="<c:choose><c:when test="${bill.freeBill == true}">zero</c:when><c:otherwise>${bill.amount}</c:otherwise></c:choose>">

<script>
	function printDiv() {
		jQuery("div#printDiv").printArea({
			mode : "iframe"
		});
		jQuery("#billForm").submit();

		//setTimeout(function(){window.location.href = $("#contextPath").val()+"/module/billing/getBill.list"}, 1000);
	}
	jQuery(document).ready(function() {
		jQuery("#totalValue2").html(toWords(jQuery("#total").val()));
	});
</script>

<%@ include file="/WEB-INF/template/footer.jsp"%>
</div>