// loading common groovy scripts
@Library('common')
@Library('humn') _

def version = "latest"
def new_version = ""
def scmURL

pipeline {
   agent { label 'ec2' }

    stages {

        stage('Versioning') {
            steps {
                script {
                    def current_version = getVersion("./")
                    echo "current version ${current_version}"
                    new_version = incrementVersion(current_version)
                    echo "new version ${new_version}"
                }
            }
        }
        stage('Tag & Push') {
            when {
                allOf {
                    branch 'master'
                }
            }

            environment {
                    VERSION = "${new_version}"
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'humn/ci/github/humnrw', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "git remote set-url origin 'https://${USERNAME}:${PASSWORD}@github.com/humn-ai/tf-mod-aws-s3-bucket'"
                    sh "git tag -a ${new_version} -m 'New version ${new_version}'"
                    sh "git push origin ${new_version}"
                }
            }
        }
    }
    post {
        always {
            deleteDir()
        }
    }
}

/**
 * Method for incrementing SemVer 2 compatible version
 *
 * @param version  String which contains main part of SemVer2 version - '2.1.0'
 * @return string  String conaining version with Patch part of version incremented by 1
 */

def incrementVersion(version){
    def parts = checkVersion(version)
    return "${parts[0]}.${parts[1]}.${parts[2].toInteger() + 1}"
}

/**
 * Method for checking whether version is compatible with Sem Ver 2
 *
 * @param version  String which contains main part of SemVer2 version - '2.1.0'
 * @return list    With 3 strings as result of splitting version by dots
 */

def checkVersion(version) {
    def splitParts = version.split('-')
    def parts = splitParts[0].tokenize('.')
    if (parts.size() != 3) {
        error "Bad version ${version}"
    }
    return parts
}

/**
 * Method for constructing SemVer2 compatible version from tag in Git repository:
 * - if current commit matches the last tag, last tag will be returned as version
 * - if no tag found assuming no release was done, version will be 0.0.1 with pre release metadata
 * - if tag found - patch part of version will be incremented and pre-release metadata will be added
 *
 *
 * @param repoDir          String which contains path to directory with git repository
 * @param allowNonSemVer2  Bool   whether to allow working with tags which aren't compatible
 *                                with Sem Ver 2 (not in form X.Y.Z). if set to true tag will be
*                                 converted to Sem Ver 2 version e.g tag 1.1.1.1rc1 -> version 1.1.1-1rc1
 * @return version  String
 */
def getVersion(repoDir, allowNonSemVer2 = false) {
    def common = new com.mirantis.mk.Common()
    dir(repoDir){
        def cmd = common.shCmdStatus('git describe --tags --first-parent --abbrev=0')
        def tag_data = [:]
        def last_tag = cmd['stdout'].trim()
        def commits_since_tag
        if (cmd['status'] != 0){
            if (cmd['stderr'].contains('fatal: No names found, cannot describe anything')){
                common.warningMsg('No parent tag found, using initial version 0.0.0')
                tag_data['version'] = '0.0.0'
                commits_since_tag = sh(script: 'git rev-list --count HEAD', returnStdout: true).trim()
            } else {
                error("Something went wrong, cannot find git information ${cmd['stderr']}")
            }
        } else {
            tag_data['version'] = last_tag
            commits_since_tag = sh(script: "git rev-list --count ${last_tag}..HEAD", returnStdout: true).trim()
        }
        try {
            checkVersion(tag_data['version'])
        } catch (Exception e) {
            if (allowNonSemVer2){
                common.errorMsg(
    """Git tag isn't compatible with SemVer2, but allowNonSemVer2 is set.
    Trying to convert git tag to Sem Ver 2 compatible version
    ${e.message}""")
                tag_data = prepareTag(tag_data['version'])
            } else {
                error("Git tag isn't compatible with SemVer2\n${e.message}")
            }
        }
        // If current commit is exact match to the first parent tag than return it
        def pre_release_meta = []
        if (tag_data.get('extra')){
            pre_release_meta.add(tag_data['extra'])
        }
        if (common.shCmdStatus('git describe --tags --first-parent --exact-match')['status'] == 0){
            if (pre_release_meta){
                return "${tag_data['version']}-${pre_release_meta[0]}"
            } else {
                return tag_data['version']
            }
        }
        return tag_data['version']
    }
}