@isTest
public class SlackOpportunityPublisherTest {
    
    static testMethod void testPost() {
        Boolean success = true;
        List<Account> accList = new List<Account>();
        try {
            accList = RFO_Utility_Test.createProspectAccounts();
            system.assert(accList.size()>0);
            Database.insert(accList);
            Pricebook2 pbook = new Pricebook2(
                Name = 'Standard Price Book',
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            Database.update(pbook);
            Opportunity opp = new Opportunity(Name='test opportunity', StageName='Close Won', CloseDate=date.today());
            opp.AccountId= accList[0].Id;
            insert opp;
            SlackOpportunityPublisher.postToSlack(new List<Id> { opp.Id });
        } catch (Exception e) {
            success = false;
        } finally {
            System.assert(success);
        }
    }
    
}