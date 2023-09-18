{ stdenv, lib
  , fetchurl
  , writeShellScriptBin
  , symlinkJoin
  , jdk17
}:

let 

  version = "1.27.1";
  binName = "jdt-language-server-1.27.1-202309140221";

  src = fetchurl {
    url = "https://download.eclipse.org/jdtls/milestones/${version}/${binName}.tar.gz";
    sha256 = "iGarmMlVflTmi949+LJ/seSgw6F4Wn+OFszyZ7xbWsU=";
  };

  jdtls = stdenv.mkDerivation rec {

    name = "eclipse-jdt-language-server-${version}";
    inherit src;

    sourceRoot = ".";

    installPhase = ''
      mkdir -p "$out/jdtls"
      cp -R "config_linux" "config_ss_linux" "features" "plugins" "$out/jdtls"
    '';

    meta = with lib; {
      homepage = "https://github.com/eclipse/eclipse.jdt.ls";
      description = "Eclipse JDT Language Server";
      longDescription = ''
        The Eclipse JDT Language Server is a Java language specific implementation of the Language Server Protocol
        and can be used with any editor that supports the protocol, to offer good support for the Java Language.
      '';
      platforms = platforms.linux;
      maintainers = with maintainers; [ marc-jakobi ];
    };

  };
        #-Xbootclasspath/a:/home/paul/.m2/repository/org/projectlombok/lombok/1.18.24/lombok-1.18.24.jar \

  jdtlsWrapper = writeShellScriptBin "jdtls" ''
      exec ${jdk17}/bin/java \
        -Declipse.application=org.eclipse.jdt.ls.core.id1 \
        -Dosgi.bundles.defaultStartLevel=4 \
        -Declipse.product=org.eclipse.jdt.ls.core.product \
        -Dosgi.checkConfiguration=true \
        -Dosgi.sharedConfiguration.area=${jdtls}/jdtls/config_linux \
        -Dosgi.sharedConfiguration.area.readOnly=true \
        -Dosgi.configuration.cascaded=true \
        -javaagent:/home/paul/.m2/repository/org/projectlombok/lombok/1.18.24/lombok-1.18.24.jar \
        -noverify \
        -Xms1G \
        -jar ${jdtls}/jdtls/plugins/org.eclipse.equinox.launcher_*.jar \
        "$@"
    '';
    
in symlinkJoin {
  name = "jdtls";
  paths = [ jdtls jdtlsWrapper ];
}
