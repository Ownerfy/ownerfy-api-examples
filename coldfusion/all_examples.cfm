<!--- NFT Minting with ColdFusion --->
<!--- The code accesses Ownerfy API to interact with the Polygon blockchain --->
<!--- to access, mint and transfer NFTs and is created for demonstration perposes only, not for production. --->
<!--- Created by Masha Edelen, October 3rd 2022 --->
<!--- To access Ownerfy API go to ownerfy.com --->


<cfscript>

apiKey = "101d478c-1188-4747-909a-8545ab89ba57";
apiURL = "https://ownerfy.com/api/v1";
timeout = 45;

// GET handler
private any function getRequest(required string gatewayURL, string requestData){

    var httpRequest = new http();
    httpRequest.setMethod("GET");
    httpRequest.setUrl(arguments.gatewayURL);
    httpRequest.setTimeout(variables.timeout);

    httpRequest.addParam(type="header",name="authorization",value="Bearer #variables.apiKey#");

    var response = httpRequest.send().getPrefix();

    return response;
}


//POST handler
private any function postRequest(required string gatewayURL, required string requestData){

    var httpRequest = new http();
    httpRequest.setMethod("POST");
    httpRequest.setUrl(arguments.gatewayURL);
    httpRequest.setTimeout(variables.timeout);

    httpRequest.addParam(type="header",name="authorization",value="Bearer #variables.apiKey#");

    if (len(arguments.requestData) and isJson(arguments.requestData)){

        httpRequest.addParam(type="body",name="body",value="#arguments.requestData#");
        httpRequest.addParam(type="header",name="Content-Type",value="application/json");
    }

    var response = httpRequest.send().getPrefix();

    return response;
}


private any function processResponse(required struct response) {

    var returnContent = {};

    if (arguments.response.Statuscode != "200 OK"){

        returnContent = {
            message = "Error: '#arguments.response.fileContent#'. Please try again later.",
            messageType = 'error',
            success = false
        }

    } else {

        returnContent = deserializeJSON(arguments.response.fileContent);

    }

    return returnContent;

}


//GET functions
private any function getCollections(){

    result = processResponse(getRequest("#apiURL#/collection/get"));
    return result;

}

private any function getAllNFTs(){

    result = processResponse(getRequest("#apiURL#/nft/list"));

    return result;

}

private any function getAllUsers(){

    result = processResponse(getRequest("#apiURL#/user/list"));

    return result;

}

private any function getNFTsByAddress(required string address){

    result = processResponse(getRequest("#apiURL#/nft/list/address/#arguments.address#"));

    return result;

}


//POST functions
private any function createCollection(required string name){

    newCollection = {};

    newCollection['name'] = arguments.name;

    result = processResponse(postRequest("#apiURL#/collection/create",serializeJSON(newCollection)));

    return result;

}

private any function mintNFTs(required string contract, required array NFTs){

    NFTStruct = {};

    NFTStruct['contract'] = arguments.contract;
    NFTStruct['nfts'] = arguments.NFTs;

    result = processResponse(postRequest("#apiURL#/nft/create",serializeJSON(NFTStruct)));

    return result;

}

private any function createUser(required string userName, required string email, required string phoneNumber){

    newUser = {};

    newUser['userName'] = arguments.userName;
    newUser['email'] = arguments.email;
    newUser['phoneNumber'] = arguments.phoneNumber;

    result = processResponse(postRequest("#apiURL#/user/create",serializeJSON(newUser)));

    return result;

}

private any function transferNFTs(required string contract, required string toAddress, required string tokenIdList){

    nftStruct = {};
    nftStruct['nfts'] = [];

    for (tokenID in arguments.tokenIDList) {
        nft = {};
        nft['contract'] = arguments.contract;
        nft['toAddress'] = arguments.toAddress;
        nft['blockchainTokenId'] = tokenID;
        arrayAppend(nftStruct['nfts'],nft);
    }

    result = processResponse(postRequest("#apiURL#/nft/transfer",serializeJSON(nftStruct)));

    return result;

}


//ALL DATA

// get all colections
allCollections = getCollections();

// get all NFTs
NFTList = getAllNFTs();

//get all users
userList = getAllUsers();


// ORDER:
// Create collection
// Mint NFTs
// Create new user
// Transfer NFT

// CREATE

// create new collection
// newCollection = createCollection("CFSummit22");
// cfdump(var='#newCollection#', top='2');
// abort;

// create a new user
// userResult = createUser("cfuser","cfuser@ownerfy.com","310-333-333");
// cfdump(var='#userResult#', top='2');
// abort;


// NFT Minting

// find the right contract address for minting
if (isArray(allCollections)) {
    for (collection in allCollections){
        if (collection.name == "CFSummit22") {
            contractAddress = collection.address;
        }
    }
}


// Build NFT(s) info
    newNFT1 = {};
    newNFT1['name'] = "CFSummit 2022";
    newNFT1['description'] = "Premier ColdFusion Conference 2022 in Las Vegas";
    newNFT1['image'] = "https://firebasestorage.googleapis.com/v0/b/receiptcoin-receiptchain-de560.appspot.com/o/website%2Fnftdemo%2FScreen_Shot_2022-10-02_at_9.03.26_PM.png?alt=media&token=3a6fbdce-4d97-4f51-b7c5-3fa6b31bdff6"

    newNFT2 = {};
    newNFT2['name'] = "Zombie Friends";
    newNFT2['description'] = "NFT Collection by Justin Pierce";
    newNFT2['image'] = "https://firebasestorage.googleapis.com/v0/b/receiptcoin-receiptchain-de560.appspot.com/o/collections%2Fzombiefriends%2Fjpzombies_hero.png?alt=media&token=fb5bb945-f862-44da-9993-f67dc6cabe58"

    NFTs = [];
    NFTs[1] = newNFT1;
    NFTs[2] = newNFT2;


// MINTING

// if (structKeyExists(variables,'contractAddress')) {
//     mintResult = mintNFTs("#contractAddress#","#NFTs#");
//     cfdump(var='#mintResult#');
// } else {
//     cfdump(var='#allCollections#', top='2');
// }
// abort;


//TRANSFER

// transfer NFT(s)
// if (structKeyExists(variables,'contractAddress')) {
//     transferResult = transferNFTs(contractAddress,'0xb6c319DCa7EC14A6eb2072443131939e696762bB','18572033062');
//     cfdump(var='#transferResult#');
// } else {
//     cfdump(var='#allCollections#', top='2');
// }
// abort;

</cfscript>

<!DOCTYPE html>
<html lang="en" class="no-js" >
<head>

    <title>ColdFusion NFT Minting</title>

    <link rel="stylesheet" href="css/styles.css">

</head>

<!--- ALL DATA --->

<!--- get all colections --->
<h2>All Collections</h2>
<cfif isArray(allCollections) and !arrayIsEmpty(allCollections)>
    <cfdump var='#allCollections#' label="All Collections">
<cfelseif isArray(allCollections) and arrayIsEmpty(allCollections)>
    No collections exist.
<cfelse>
    <cfdump var='#allCollections#' top='2'>
</cfif>

<!--- get all NFTs --->
<h2>All NFTs</h2>
<cfif isArray(NFTList) and !arrayIsEmpty(NFTList)>
    <cfloop array="#NFTList#" index="thisNFT">
        <cfdump var='#thisNFT#' top='2'>
        <cfoutput>
            <img src="#thisNFT.image#" width="500">
        </cfoutput>
    </cfloop>
<cfelseif isArray(NFTList) and arrayIsEmpty(NFTList)>
    No NFTs found
<cfelse>
    <cfdump var='#NFTList#' top='2'>
</cfif>

<!--- get all users --->
<h2>All Users</h2>
<cfif isArray(userList) and !arrayIsEmpty(userList)>
    <cfdump var='#userList#' label="All Users">
<cfelseif isArray(userList) and arrayIsEmpty(userList)>
    No users created.
<cfelse>
    <cfdump var='#userList#' label="All Users">
</cfif>

<!--- get all NFTs for user
<!--- possibly Mark Cuban's address: 0x95abDa53Bc5E9fBBDce34603614018d32CED219e --->
<h2>Get NFTs by Public Address</h2>
<cfset pubicAddress = '0x95abDa53Bc5E9fBBDce34603614018d32CED219e'>
<cfset NFTsByAddress = getNFTsByAddress(pubicAddress)>
<cfif isArray(NFTsByAddress) and !arrayIsEmpty(NFTsByAddress)>
    <cfloop array="#NFTsByAddress#" index="thisNFT">
        <cfdump var='#thisNFT#' top='2'>
        <cfoutput>
            <img src="#thisNFT.image#" width="500">
        </cfoutput>
    </cfloop>
<cfelseif isArray(NFTsByAddress) and arrayIsEmpty(NFTsByAddress)>
    No NFTs for the user with address
    <cfoutput>
        #pubicAddress#
    </cfoutput>
<cfelse>
    <cfdump  var="#NFTsByAddress#">
</cfif>
--->

</body>
</html>
