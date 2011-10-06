<%@ include file="/WEB-INF/template/include.jsp" %>
<openmrs:require privilege="Add Bill" otherwise="/login.htm" redirect="/module/billing/main.form" />

<%@ include file="/WEB-INF/template/header.jsp" %>
<script type="text/javascript" src="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/jquery-ui-1.8.2.custom.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/moduleResources/billing/scripts/common.js"></script>
<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/css/start/jquery-ui-1.8.2.custom.css" />
<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/moduleResources/billing/styles/common.css" />
<style>
	.detailDiv{z-index: 100;border:1px solid black; display: none; position: absolute; background-color:#CFE7FF;padding:3px;}
</style>
<c:forEach items="${errors.allErrors}" var="error">
	<span class="error"><spring:message code="${error.defaultMessage}" text="${error.defaultMessage}"/></span><
</c:forEach>
<script>
	jQuery(document).ready(function(){
		jQuery(".udiv").hover(
				function(){
					jQuery(this).children("div.detailDiv:first").show();
				}
				,function(){
					jQuery(this).children("div.detailDiv:first").hide();
				});
	});
</script>
<c:if test="${not empty listMiscellaneousService }">
<div id="tabs">
<ul>
	<li><a href="#fragment" style="color: white"><span>List Miscellaneous Services</span></a></li>
</ul>
<div id="fragment">
	<c:forEach items="${listMiscellaneousService}" var="service">
		<div id="service_${service.id}"   class="udiv boxNormal" onclick="addToBill('${service.id}', '${service.name}', ${service.price} )">
			${service.name}
		</div>
	</c:forEach>
</div>
</div>
</c:if>

<script type="text/javascript">
	function addToBill(serviceId, name, price) {
		var colorSelected = "rgb(170, 255, 170)";
		if(document.getElementById("billItem") != null){
			deleteInput(serviceId, name);
		}
       	var htmlText =  "<input  type='text'  size='16'  value='"+name+"'  readonly='readonly'  />"
    	+"<input  type='text'  size='5' value='"+price+"' readonly='readonly' />"
    	+"<input  type='text'  size='16' id='liableName' name='name'  />"
    	+"<input  type='hidden'  name='serviceId'  value='"+serviceId+"' />"
      	+"<a style='color:red' href='#' onclick='deleteInput("+serviceId+")' >&nbsp;[X]</a>";
       	
        var newElement = document.createElement('div');
        newElement.setAttribute("id", "billItem");
        document.getElementById('totalprice').value = price;
	 	newElement.innerHTML = htmlText;

        var fieldsArea = document.getElementById('extra');
		fieldsArea.appendChild(newElement);
		document.getElementById("service_"+serviceId).style.backgroundColor=colorSelected; 
	}
		function deleteInput( serviceId ) {
			var parentDiv = 'extra';
		 	if (document.getElementById("billItem")) {     
		        var child = document.getElementById("billItem");
		        var parent = document.getElementById(parentDiv);
		        parent.removeChild(child);
		        document.getElementById('totalprice').value = "0";
		        document.getElementById("service_"+serviceId).style.backgroundColor="#FCCFFF";
		   }
		   else {
		        alert("Element has already been removed or does not exist.");
		        return false;
		   }
		}
		function validateForm(){
			$('#totalprice').focus();
			var liableName = jQuery("#liableName").val();
			if( jQuery.trim(liableName) == 0  ) {
				alert("Please enter name");
			}else{
				jQuery("#billForm").submit()
			}
		}
</script>

		<!-- Right side div for bill collection -->
		<div id="billDiv">
		<form method="POST" id="billForm" action="addMiscellaneousServiceBill.form" onsubmit="return false">
		<div> <input type="button" id="subm" onclick="validateForm()" name="subm" value="<spring:message code='billing.bill.save'/>" />
		<input type="button" value="<spring:message code='general.cancel'/>" onclick="javascript:window.location.href='miscellaneousServiceBill.list'" />
		<input type="button" id="toogleBillBtn" value="-" onclick="toogleBill(this);" class="min" style="float: right" /></div>
		<div id="total" style="background: #f6f6f6; border: 1px #808080 solid; padding: 0.3em;margin:0.3em 0em; width: 100%;">
		<input type='text' size='25' value='Total:' />&nbsp; 
		<input type='text' size='3' value='' readonly="readonly" />&nbsp;
		<input type='text' id='totalprice' name='totalprice' size='5' value='0' readonly="readonly" />&nbsp; <b>
		</div>

		<input type="hidden" name="driverId" value="${driverId}"> 
		<input type="hidden" id="serviceCount" name="serviceCount" value="0">

		<div id="extra" style="background: #f6f6f6; border: 1px #808080 solid; padding: 0.3em;margin:0.3em 0em; width: 100%;">
		<input type='text' size='16' value='Service Name' readonly='readonly' />&nbsp; 
		<input type='text' size="5" value='Price' readonly="readonly" />&nbsp;
		<input type='text' size='16' value='Name' readonly="readonly" />&nbsp;</b>
		<hr/>
		</div>
	
		
		</form>
		</div>
	
<%@ include file="/WEB-INF/template/footer.jsp" %> 