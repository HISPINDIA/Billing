/**
 *  Copyright 2009 Society for Health Information Systems Programmes, India (HISP India)
 *
 *  This file is part of Billing module.
 *
 *  Billing module is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  Billing module is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Billing module.  If not, see <http://www.gnu.org/licenses/>.
 *
 **/

package org.openmrs.module.billing.web.controller.main;

import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.math.NumberUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonAttributeType;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.billing.includable.billcalculator.BillCalculatorService;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.BillableService;
import org.openmrs.module.hospitalcore.model.PatientServiceBill;
import org.openmrs.module.hospitalcore.model.PatientServiceBillItem;
import org.openmrs.module.hospitalcore.util.HospitalCoreUtils;
import org.openmrs.module.hospitalcore.util.Money;
import org.openmrs.module.hospitalcore.util.PatientUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;


/**
 *
 */
@Controller
@RequestMapping("/module/billing/addPatientServiceBill.form")
public class BillableServiceBillAddController {
	
	private Log logger = LogFactory.getLog(getClass());
	
	@RequestMapping(method=RequestMethod.GET)
	public String viewForm( Model model, @RequestParam("patientId") Integer patientId,
	@RequestParam(value = "comment", required = false) String comment){
		BillingService billingService = Context.getService(BillingService.class);
		List<BillableService> services = billingService.getAllServices();
    	Map<Integer, BillableService> mapServices = new HashMap<Integer, BillableService>();
		for(BillableService ser : services){
				mapServices.put(ser.getConceptId(), ser);
		}
		Integer conceptId = Integer.valueOf(Context.getAdministrationService().getGlobalProperty("billing.rootServiceConceptId"));
		Concept concept = Context.getConceptService().getConcept(conceptId);
		model.addAttribute("tabs", billingService.traversTab(concept, mapServices, 1));
		model.addAttribute("patientId", patientId);
		return "/module/billing/main/billableServiceBillAdd";
	}
	
	@RequestMapping(method=RequestMethod.POST)
	//New Requirement add Paid bill & Free bill Both 
	public String onSubmit(Model model,Object command, BindingResult bindingResult, HttpServletRequest request,
	                       @RequestParam("cons") Integer[] cons,@RequestParam(value = "billType", required = false) String billType,
	                       @RequestParam(value = "comment", required = false) String comment,
	                       @RequestParam("patientId") Integer patientId,
	                       @RequestParam(value = "totalprice", required = false) float totalprice,
	                       @RequestParam(value = "waiverPercentage", required = false) float waiverPercentage,
	                       @RequestParam(value= "waiverComment", required = false) String waiverComment,
	                       @RequestParam(value = "spclPercntage", required = false) float spclwardPercentage,
	           			   @RequestParam(value = "totalAmountPayable", required = false) BigDecimal totalAmountPayable,
	           			   @RequestParam(value = "amountGiven", required = false) Integer amountGiven,
	           			   @RequestParam(value = "amountReturned", required = false) Integer amountReturned){
		validate(cons, bindingResult, request);		
		if( bindingResult.hasErrors()){
			model.addAttribute("errors", bindingResult.getAllErrors());
			return "module/billing/main/billableServiceBillEdit";
		}
		
		BillingService billingService = Context.getService(BillingService.class);

		PatientService patientService = Context.getPatientService();
		
		// Get the BillCalculator to calculate the rate of bill item the patient has to pay
		Patient patient = patientService.getPatient(patientId);
		Map<String, String> attributes = PatientUtils.getAttributes(patient);
		BillCalculatorService calculator = new BillCalculatorService();
		
		PatientServiceBill bill = new PatientServiceBill();
		bill.setCreatedDate(new Date());
		bill.setPatient(patient);
		bill.setCreator(Context.getAuthenticatedUser());
		
		
		PatientServiceBillItem item = null;
		int quantity = 0;
		Money itemAmount;
		Money mUnitPrice;
		Money totalAmount = new Money(BigDecimal.ZERO);
		BigDecimal totalActualAmount = new BigDecimal(0);
		BigDecimal unitPrice;
		String name ;
		BillableService service ;
		
		for( int conceptId : cons){
		
			unitPrice = NumberUtils.createBigDecimal(request.getParameter(conceptId+"_unitPrice"));
			quantity = NumberUtils.createInteger(request.getParameter(conceptId+"_qty"));
			name = request.getParameter(conceptId+"_name");
			service = billingService.getServiceByConceptId(conceptId);

			mUnitPrice = new Money(unitPrice);
			itemAmount = mUnitPrice.times(quantity);
			totalAmount = totalAmount.plus(itemAmount);
			
			item = new PatientServiceBillItem();			
			item.setCreatedDate(new Date());
			item.setName(name);
			item.setPatientServiceBill(bill);
			item.setQuantity(quantity);
			item.setService(service);
			item.setUnitPrice(unitPrice);		
			
			item.setAmount(itemAmount.getAmount());
			
			// Get the ratio for each bill item
			Map<String, Object> parameters = HospitalCoreUtils.buildParameters("patient", patient, "attributes", attributes, "billItem", item, "request", request);
			BigDecimal rate = calculator.getRate(parameters,billType);	
			item.setActualAmount(item.getAmount().multiply(rate));
			totalActualAmount = totalActualAmount.add(item.getActualAmount());
			
			bill.addBillItem(item);
		}
		
		bill.setComment(comment);
		bill.setAmount(totalAmount.getAmount());	
		bill.setActualAmount(totalActualAmount);
		
		//New Requirement add Paid bill & Free bill Both 
		/*bill.setFreeBill(calculator.isFreeBill(HospitalCoreUtils
				.buildParameters("attributes", attributes)));
		logger.info("Is free bill: " + bill.getFreeBill());*/
		
		//new requirement capture 'patient_category'
		HospitalCoreService hcs = Context.getService(HospitalCoreService.class);
		List<PersonAttribute> pas = hcs.getPersonAttributes(patientId);
		String patientCategory = "";
       for (PersonAttribute pa : pas) {
            PersonAttributeType attributeType = pa.getAttributeType();
            if(pa.getAttributeType().getId()==14)
            {
            	patientCategory = pa.getValue();
            	  bill.setPatientCategory(patientCategory);
            }
       }
     //New Requirement add Paid bill & Free bill Both 
       bill.setFreeBill(calculator.isFreeBill(billType));
		logger.info("Is free bill: " + bill.getFreeBill());
		bill.setReceipt(billingService.createReceipt());
		//new requirement discount and spcl ward
		bill.setWaiverPercentage(waiverPercentage);
		float waiverAmount=totalprice*waiverPercentage/100;
		bill.setWaiverAmount(waiverAmount);
		
		bill.setSpclwardPercentage(spclwardPercentage);
		float spclwardAmount=totalprice*spclwardPercentage/100;
		bill.setSpclwardAmount(spclwardAmount);
		bill.setAmountPayable(totalAmountPayable);
		bill.setAmountGiven(amountGiven);
		bill.setAmountReturned(amountReturned);
		bill.setComment(waiverComment);
		bill = billingService.savePatientServiceBill(bill);		
		return "redirect:/module/billing/patientServiceBill.list?patientId="+patientId+"&billId="+bill.getPatientServiceBillId();
		
	}
	
	private void validate(Integer[] ids, BindingResult binding, HttpServletRequest request){
		for( int id : ids){
			try {
	            Integer.parseInt(request.getParameter(id+"_qty"));
            }
            catch (Exception e) {
            	binding.reject("billing.bill.quantity.invalid", "Quantity is invalid");
            	return;
            }
		}
	}
}
