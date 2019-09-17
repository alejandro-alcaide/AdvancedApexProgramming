// TestBulkPatterns.initTestObjects
public class TestBulkPatterns {

    // Prepare the specified number of Opportunities with Contact Roles on each.
    // The Contact Roles are distributed evenly among the number of Contacts specified.
    public static void initTestObjects (
        List<Opportunity> newOpportunities,
        Integer numberOfOpportunities,
        Integer numberOfOtherOpportunities,
        Integer contactRolesPerOpp,
        Integer numberOfContacts) {

            if(numberOfContacts < contactRolesPerOpp)
                numberOfContacts = contactRolesPerOpp;

            List<Contact> cts = new List<Contact>();
            for(Integer x=0; x<numberOfContacts; x++) {
                cts.add(new Contact(LastName = 'cttest_' + String.valueOf(x)));
            }
            insert cts;

            /* The code for creating Contacts and Opportunities shows a common Test Pattern to 
            * create a specified number of objects with different names or other field values.
            */
            newOpportunities.clear();
            for(Integer x=0; x<numberOfOpportunities; x++) {
                newOpportunities.add(
                    new Opportunity(
                        CloseDate = Date.Today().addDays(5),
                        Name = 'optest_' + String.valueOf(x),
                        StageName = 'Prospecting'    
                    )
                );
            }
            insert newOpportunities;

            List<Opportunity> otherOpportunities = new List<Opportunity>();
            for(Integer x=0; x<numberOfOtherOpportunities; x++) {
                otherOpportunities.add(
                    new Opportunity(
                        CloseDate = Date.Today().addDays(5),
                        Name = 'optest_' + String.valueOf(x + numberOfOpportunities),
                        StageName = 'Prospecting'
                    )
                );
            }
            insert otherOpportunities;

            // Combine newOpportunities and otherOpportunities for creating OpportunityContactRoles
            otherOpportunities.addAll(newOpportunities);

            // Now insert Contact Roles
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            Integer contactNumber = 0;
            for(Opportunity op: otherOpportunities) {
                for(Integer ocrNumber = 0; ocrNumber < contactRolesPerOpp; ocrNumber++) {
                    ocrList.add(
                        new OpportunityContactRole(
                            OpportunityId = op.id,
                            ContactId = cts[contactNumber].id
                        )
                    );
                    contactNumber++;
                    if(contactNumber >= numberOfContacts)
                        contactNumber = 0;
                }
            }
            insert ocrList;
        }

        /* Test utility function that takes a list of Opportunity Objects and makes sure that each 
        * one has a primary Contact.
        */
        public static void validateOCRs(List<Opportunity> opps) {
            // get map for IDs
            Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>(opps);

            // Query for primary Contacts
            List<OpportunityContactRole> ocrs =
                [SELECT ID, OpportunityID 
                FROM OpportunityContactRole 
                WHERE OpportunityId IN :oppMap.keyset()
                AND isPrimary = TRUE];
            
            // Create OpportunityIDs Set with Primary Contacts
            Set<ID> opportunitiesWithPrimaryContact = new Set<ID>();
            for(OpportunityContactRole ocr: ocrs) {
                opportunitiesWithPrimaryContact.add(ocr.OpportunityID);
            }

            // Now make sure every Opportunity has a Primary Contact Role
            for(Opportunity opp: opps) {
                System.Assert(opportunitiesWithPrimaryContact.contains(op.id));
            }

        }
    // EOMethod initTestObjects
    }

    // This functional test demonstrates how easy it is to tie the utility functions together.
    static testMethod void bulkOpportunityTest() {
        List<Opportunity> opps = new List<Opportunity>();
        /* (you may need to adjust these numbers)
         *      List<Opportunity> newOpportunities, 
                numberOfOpportunities, 
                numberOfOtherOpportunities,
                contactRolesPerOpp,
                numberOfContacts
         */
        initTestObjects(opps, 100, 15, 15, 40);

        /* The bulkOpportunityTest test and utility functions validate the part of the 
         * requirements which ensure that a Primary Contact exists for Opportunities already
         * associated with Contacts.   
         */
        Test.StartTest();
        for(Opportunity opp: opps) {
            opp.StageName = 'Qualification';
        }
        update opps;
        Test.StopTest();

        validateOCRs(opps);
    } // EOMethod bulkOpportunityTest

    static testMethod void createTaskTest() {
        Integer numberOfOpportunities = 100;
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer x=0; x<numberOfOpportunities; x++) {
            opps.add(new Opportunity(
                CloseDate = Date.Today().addDays(5),
                Name = 'optest_' + String.valueOf(x),
                StageName = 'Prospecting')
            );
        }
        insert opps;

        /* The createTaskTest method tests the condition where there are no Contacts 
         * associated with an Opportunity. 
         */
        Test.StartTest();
        for(Opportunity opp: opps) {
            opp.StageName = 'Qualification';
        }
        update opps;
        Test.StopTest();

        List<Task> tasks = [
            SELECT ID, OwnerID, WhatID, Status, Subject, Type
            FROM Task
            WHERE OwnerID = :UserInfo.getUserID()
            AND TYPE = 'Other'
            AND IsClosed = FALSE
            AND Subject = 'Assign Primary Contact'
        ];
        system.assertEquals(numberOfOpportunities, tasks.size());

    } // EOMethod createTaskTest

    public static void afterUpdateOpportunityCommon(
        List<Opportunity> newList, 
        Map<ID, Opportunity> newMap,
        Map<ID, Opportunity> oldMap
    ) {
        // Pattern 2 - Straightforward common implementation
        
        Set<ID> opportunityIDsWithStagenameChanges = new Set<ID>();

    }

} // EOClass TestBulkPatterns