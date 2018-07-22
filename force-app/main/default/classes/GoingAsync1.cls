/*Copyright (c) 2018, Daniel Appleman

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
public class GoingAsync1 {

	// Simple protection from workflows and triggers
	private static Boolean alreadyProcessed = false;	

	public static void handleTrigger1(List<WorkOrder> workOrderList, 
		Map<ID, WorkOrder> newMap, Map<ID, WorkOrder> oldMap, 
		TriggerOperation operation)
	{
		if(alreadyProcessed) return;
		alreadyProcessed = true;
		if(operation == TriggerOperation.AFTER_INSERT) firstAttempt(newMap.keyset());
		else
		{
			Set<ID> textChangedIds = new Set<ID>();
			for(WorkOrder wo: workOrderList)
			{
				if(wo.Description!= oldMap.get(wo.id).Description) 
					textChangedIds.add(wo.id); 
			}
			if(textChangedIds.size()>0) firstAttempt(textChangedIds);
		}

	}

	@future(callout=true)
	public static void firstAttempt(Set<ID> workOrderIds)
	{
		List<WorkOrder> workOrdersToUpdate = 
			[SELECT ID, Description, DescriptionSpanish__c 
			from WorkOrder where ID in :workOrderIds];
		for(WorkOrder wo: workOrdersToUpdate) 
			wo.DescriptionSpanish__c = SimulatedTranslator.translate(wo.Description);
		update workOrdersToUpdate;
	}

}