@isTest
public class lookupAssetsMultiACTest {
    
    @isTest
    public static void getAssetTest(){
        Account acc = new Account();
        acc.Name = 'Test acc';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'Test';
        ast.AccountId = acc.Id;
        insert ast;
        
        lookupAssetsMultiAC.getAsset(ast.Id);
        lookupAssetsMultiAC.getAssetById(ast.Id);
        lookupAssetsMultiAC.getAssetName(ast.Id);
        lookupAssetsMultiAC.getAssetCommodity(ast.Id);
    }
}