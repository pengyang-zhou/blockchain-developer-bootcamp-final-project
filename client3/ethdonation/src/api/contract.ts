import Web3 from 'web3'
import EthDonation from './EthDonation.json'

const web3 = new Web3(window.ethereum);
const contract = new web3.eth.Contract(EthDonation.abi, '0xD42A1Dc69e88E3518E77381D889454446d73ea2F');

function addListener(fn: Function) {
    //@ts-ignore
    ethereum.on('accountsChanged', fn)
}

async function authenticate() {
    //@ts-ignore
    await window.ethereum.enable();
}

async function getAccount() {
    return (await web3.eth.getAccounts())[0];
}

export declare interface Project {
    index: number,
    founder: string,
    title: string,
    description: string,
    endTime: number,
    amountFunded: number,
    amountLeft: number,
    expenseCount: number
}

export declare interface Expense {
    index: number,
    description: string,
    allocation: number,
    approvedAmount: number,
    state: number
}

export declare interface Donation {
    donator: string,
    total: number,
    available: number
}

async function getProjects() : Promise<Project[]> {
    const projectCount = await contract.methods.projectCount().call();
    const projects = [];
    for (let i=1; i<=projectCount; i++) {
        projects.push(await getProject(i));
    }
    return projects;
}

async function getProject(index:number) : Promise<Project> {
    const data = await contract.methods.projects(index).call();
    data.amountFunded = Web3.utils.fromWei(data.amountFunded, 'ether');
    data.amountLeft = Web3.utils.fromWei(data.amountLeft, 'ether');
    return {index, ...data};
}

async function getProjectExpenses(projectId:number) : Promise<Expense[]> {
    const expenseCount = 2;
    const expenses = [];
    for(let i=1; i<=expenseCount; i++) {
        expenses.push({
            index: i,
            description: "description",
            allocation: i,
            approvedAmount: 0,
            state: 0
        });
    }
    return expenses;
}

async function getProjectDonations(projectId: number) : Promise<Donation[]> {
    const donationCount = 2;
    const donations = [];
    for(let i=1; i<=donationCount; i++) {
        donations.push({
            donator: "donator",
            total: i,
            available: i
        });
    }
    return donations;
}

export {
    getAccount,
    authenticate,
    contract,
    addListener,
    getProjects,
    getProject,
    getProjectExpenses,
    getProjectDonations
}

