"""
Trap Processor - Extracts key information from SNMP trap messages
Ready to consume data from RabbitMQ
"""
import re
import json

class clean_trap:
    
    def extract_trap_info(trap_data):
        """
        Extracts key information from a trap message.
        
        Args:
            trap_data (str): The raw trap message text
            
        Returns:
            dict: Dictionary containing extracted information or None if extraction fails
        """
        # Combined regex pattern to extract all information at once
        pattern = r'^(\d{2}:\d{2}:\d{2} \d{4}/\d{2}/\d{2})\s+PDU INFO:.*?SNMPv2-MIB::snmpTrapOID\.0\s+type=\d+\s+value=OID: ADTRAN-GENGPON-MIB::([^\n]+).*?SNMPv2-MIB::sysName\.0\s+type=\d+\s+value=STRING: "([^"]+)".*?IF-MIB::ifDescr\.\d+\s+type=\d+\s+value=STRING: "Shelf: (\d+), Slot: (\d+), Pon: (\d+), ONT: (\d+), ONT Serial No: ([^,]+), ONT Reg ID: "'
        
        match = re.search(pattern, trap_data, re.DOTALL)
        
        if match:
            return {
                'timestamp': match.group(1),
                'trap_type': match.group(2),
                'olt_name': match.group(3),
                'ont_location': f"{match.group(7)}@{match.group(4)}/{match.group(5)}/{match.group(6)}",
                'ont_serial': match.group(8)
            }
        
        return None


    def process_trap_message(message):
        """
        Processes a trap message and returns structured data ready for RabbitMQ.
        
        Args:
            message (str): Raw trap message
            
        Returns:
            dict: Structured data with timestamp and serial number, or None if processing fails
        """
        extracted = extract_trap_info(message)
        
        if extracted:
            return {
                'timestamp': extracted['timestamp'],
                'serial': extracted['ont_serial'],
                'trap_type': extracted['trap_type'],
                'olt_name': extracted['olt_name'],
                'ont_location': extracted['ont_location']
            }
        
        return None


    # Example usage
    if __name__ == "__main__":
        # Example trap data
        trap_data = '''15:54:12 2026/01/17 PDU INFO:
    version                        1
    notificationtype               INFORM
    community                      public
    receivedfrom                   UDP: [10.242.102.12]:161->[10.241.6.48]:162
    errorindex                     0
    requestid                      197295
    transactionid                  6353668
    errorstatus                    0
    messageid                      0
    VARBINDS:
    DISMAN-EVENT-MIB::sysUpTimeInstance type=67 value=Timeticks: (657652704) 76 days, 2:48:47.04
    SNMPv2-MIB::snmpTrapOID.0      type=6  value=OID: ADTRAN-GENGPON-MIB::adGenGponOntSetLOSAlarm
    ADTRAN-GENTRAPINFORM-MIB::adTrapInformSeqNum.0 type=2  value=INTEGER: 197295
    SNMPv2-MIB::sysName.0          type=4  value=STRING: "FB-SK-OLT-03"
    IF-MIB::ifDescr.1647320064     type=4  value=STRING: "Shelf: 1, Slot: 2, Pon: 12, ONT: 7, ONT Serial No: ADTN2424dc6c, ONT Reg ID: "
    IF-MIB::ifIndex.1647320064     type=2  value=INTEGER: 1647320064
    ADTRAN-GENGPON-MIB::adGenGponOntAlarmSlotLosLevel.2 type=2  value=INTEGER: 5
    ADTRAN-GENGPON-MIB::adGenGponOntProvEntry.35.1647320064 type=2  value=INTEGER: 2
    '''
        
        result = process_trap_message(trap_data)
        
        if result:
            print("Extracted information:")
            print(json.dumps(result, indent=2))
        else:
            print("No information could be extracted from the trap data")
