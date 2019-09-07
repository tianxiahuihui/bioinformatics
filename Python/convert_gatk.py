
import sys, getopt, os

def parse_ped_file(ped_file):
    ped_reader = open(ped_file)
    lines = ped_reader.readlines()
    trio = ['', '', '']
    for line in lines:
        record = line.split()
        if(record[2] == '0' and record[3] == '0' and record[4] == '1'):
            trio[0] = record[1]
        if(record[2] == '0' and record[3] == '0' and record[4] == '2'):
            trio[1] = record[1]
        if(record[2] != '0' and record[3] != '0'):
            trio[2] = record[1]
    ped_reader.close()
    return trio

def str_wrap_by(start_str, end_str, line):
    start = line.find(start_str)
    if start >= 0:
        start += len(start_str)
        end = line.find(end_str)
        if end >= 0:
            return line[start:end].strip()

def get_family_id(ped_file):
    ped_reader = open(ped_file)
    first_line = ped_reader.readline()
    ped_reader.close()
    return first_line.split()[0]

def get_gt(genotype):
    return genotype.split(':')[0]

def get_dp(genotype):
    return genotype.split(':')[2]

def dp_passed(f_dp, m_dp, o_dp, min_dp):
    if(f_dp >= min_dp and m_dp >= min_dp and o_dp >= min_dp):
        return True
    
def is_denovo(f_gt, m_gt, o_gt):
    if((f_gt == '0/0' or f_gt== '0|0') and (m_gt == '0/0' or m_gt=='0|0') and (o_gt == '0/1' or o_gt=='0|1' or o_gt=='1|0')):
        return True
    
def parse(vcf_file, ped_file, min_dp):
    trio = parse_ped_file(ped_file)
    family_id = get_family_id(ped_file)
    vcf_reader = open(vcf_file)
    lines = vcf_reader.readlines()
    samples = ['', '', '']
    for line in lines:
        if(line.startswith('#CHROM')):
            record = line.split()
            samples[0] = record[9]
            samples[1] = record[10]
            samples[2] = record[11]
        if(not line.startswith('#') and 'DP' in line.split()[8]):
            record = line.split()
            genotypes = dict()
            genotypes[samples[0]] = record[9]
            genotypes[samples[1]] = record[10]
            genotypes[samples[2]] = record[11]
            f_gt = get_gt(genotypes[trio[0]])
            m_gt = get_gt(genotypes[trio[1]])
            o_gt = get_gt(genotypes[trio[2]])
            if(is_denovo(f_gt, m_gt, o_gt)):
                f_dp = get_dp(genotypes[trio[0]])
                m_dp = get_dp(genotypes[trio[1]])
                o_dp = get_dp(genotypes[trio[2]])
                if(not f_dp=='.'and not m_dp=='.' and not o_dp=='.'and dp_passed(int(f_dp), int(m_dp), int(o_dp), int(min_dp))):
                    print family_id + ',' + record[0].strip() + ',' + record[1].strip()
    vcf_reader.close()

def usage():
    print 'Usage: ' + sys.argv[0] + ' [OPTIONS]'
    print 'OPTIONS:'
    print '-p, --ped\t<FILE>\tpedigree file (required)'
    print '-v, --vcf\t<FILE>\tgatk output vcf file (required)'
    print '-d, --depth\t<INT>\tmin read depth (optional, default 10)'
    print '-h, --help\t\thelp information (optional)'
    
def isValidated(vcf_path, ped_path, min_dp):
    is_passed = True
    if (not os.path.isfile(vcf_path)):
        print '##ERROR: The gatk output vcf file is not correctly specified!'
        is_passed = False
    if (not os.path.isfile(ped_path)):
        print '##ERROR: The pedigree file is not correctly specified!'
        is_passed = False
    if (not (min_dp[0] == '-' and min_dp[1:] or min_dp).isdigit()):
        print '##ERROR: The min_dp must be an integer!'
        is_passed = False
    return is_passed

def main():
    try:
        opts, args= getopt.getopt(sys.argv[1:], 'p:v:d:h', ['ped=', 'vcf=', 'depth=', 'help'])
    except getopt.GetoptError:
        usage()
        sys.exit()
    ped_path = ''
    vcf_path = ''
    min_dp = ''
    for op, value in opts:
        if op in ('-p', '--ped'):
            ped_path = value
        elif op in ('-v', '--vcf'):
            vcf_path = value
        elif op in ('-d', '--depth'):
            min_dp = value
        elif op in ('-h', '--help'):
            usage()
            sys.exit()
    if(min_dp == ''):
        min_dp = '10'
    if(isValidated(vcf_path, ped_path, min_dp)):
        parse(vcf_path, ped_path, min_dp)
    else:
        usage()
        sys.exit()

if __name__ == "__main__":
    main()
