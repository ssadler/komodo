#!/bin/bash

set -e

DATADIR=./benchmark-datadir

function zcash_rpc {
    ./src/zcash-cli -rpcwait -rpcuser=user -rpcpassword=password -rpcport=5983 "$@"
}

function zcashd_start {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR"
    ./src/zcashd -regtest -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 &
    ZCASHD_PID=$!
}

function zcashd_stop {
    zcash_rpc stop > /dev/null
    wait $ZCASH_PID
}

function zcashd_massif_start {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR"
    rm -f massif.out
    valgrind --tool=massif --time-unit=ms --massif-out-file=massif.out ./src/zcashd -regtest -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 &
    ZCASHD_PID=$!
}

function zcashd_massif_stop {
    zcash_rpc stop > /dev/null
    wait $ZCASHD_PID
    ms_print massif.out
}

RAWTXWITHPOUR=02000000016939161447690d28bb07215b39ae6814bc7fca7a25f11650c0545eced95e365e00000000484730440220309ff19ffdabbfdcaf172c876a8f89b417d15c76a1f821fc2bfff4027586e29602202d0df763fe8cbc133624774e45b123d2e9dc90a6eb875addd4ccb0cb1c0419fc01ffffffff0000000000018091d2ed000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002924bcb835eb38c98d7fc741b9f5058090492b2cca5484446d654cbcc45f664410afafd7c8dc6a971cabf3dbd7786cbffb8cf5cd56c381fae1be232d767329d110aee171f8043d9c2173d2de8d82c700cbf212d545ecbac92ee92f5c9520bb20e82c931a64c8ec14074af68eca1801283d46197c320f640f94b71afc6ce899dff953425c608c1dd6daa461362360245183c17122d2b153329c685d8a79c512f287cfc02b32e723a98ca7657e21fca74884045331403819897fa3b757f3eded5f547ac1b9be65bb909b00339a6c616f92904475336155705b8b69a08371ab3d5567a65b2ca10fe40901767354f8d78c26349650c534586241a4328a406da80f7527f80c4459ca9e41765dedc933100a84f0d3279e409e0a2fc764dfeb2e1095756c4e02169a4eef5b1a5ff9e154c3408cba9fad363c2f0f63f22233ab266fb7ee4e207d8b492daf85b9f86da636b225a63354815010e7a7cd36395134b87d291f2afcc7f24e85374b15e3a411e686038dfbd652eda123b0e7dd6fb83c84d0fe48d10757d1760cd25d8c1bf08a609ea1892ba0c367640b40fee3dcbbaa0a9acd0802ee706de37771c35245a4c1d658db79974e96073407e093b55e730d31016a5e72aa68e3cbd46fd7e087a5311143299fc0987a39982154d40b4b901e22d7afd6e63e543033411105cc6196ed7c0b15424795a9d9ee688909269e5cd44e34b057ea44e9ce0af9a2b2bf5a152fdc45d0f88b728b8133e352f41ed29bf9b2c791860b85acb9ebd39c57fbd65852232b945c0eb8029b972c534dbb7776ded36e32a4ca2105a848232b28a94842f17f9f822f4951054a98c2dd17063597a2c98333bd229a8082093ccc1d763841c341fd605eed5567a4d1bea8487b748002ef6dcdf72ee6043ee294b9182425bafe256751b1d1e813e7f07b8deead9a0be1101e20157fa78cddd2a3902b0fbbb9560352932afd86053020313331383238313537353434373932353434313139313534313739353638353931323731373537393730343539333530323239373031303839383234353733323939303339303630303230353320313637393735353535373337303738353038323038343136333038323338353037323837373932323634313939353232363538313335343735323436393837383934363838363830333732313320302032303634363938313832343636383136343736333439383637323936383337333938313535383336393734363136393233313036313632343339333130393933353132333234393239313735312032303936333639393934373532383338383930393237333532323239393437343930363239373938333536363036393837333833373230313830343839373433333535303936373432343534320a3020313437353035363735303337373337313535393031313233383834323539363032353330383531363837333437393038333834333032393538333335373539363730383339363632353538313620313532323232303839343439323735393031353132303333393931363233303430303038323536373037343830393436333638393532373837373038333335363238343230363139383133353320333138373235353831303334353533313235303839303931383535363430353236333434333534323637393831363039353032333035353733393336313734373733333737333331363532302031373030383032353631393739383733303934313830323135343731303135373433373536313833353632323035393234313836393833363336313733363536343139343139313438313435203020323134373836363032383538303031353339373532363933373535363237383536393333353039313937373034333134383831303537383638383430333832333037323538343438353337322031313331373839313630393538303635323030383130383032323539353136333532313733363932343839363131363232393238363736323933393532303032363237383530363636383731390a302031373639363736313335353231393739343635353034363532343237313237353036333734313531353734363437383730343238303137363334363939393134303338343835383235393937372038323338353937303434343834383739303031383030363131393538323239373732363835333835363832353634363534373834393438333038353533373137353235343235313235363437203020313932393935303230343630393332303635303038323732333937363835363735363332393133373836343334343230353834373238333637393635353630333733383334373337303735343220353138343739303934393431393533303736323338343638353431363231363831393331373239333238393433343136303836323232343938343938343934393132383433313938333836330a302031363937353431353932323334393735343434393138373530333135303631353637303431363531343435353936393439343233383935383333373635363030303931343634383730353332372031313332373338303536323637353438383035313232373838313730313235313131353438393630393934323137313231343232363139303132353132363039323235323337353436373737370a3020313634373338353238383338383431373132353639393134333330323436373437343038343233303237313739323232313139303237383637333438303537303031303437323032323734343120343134373933323338343537393731343135323039353631383331373931383534323835363539363130373634373537323938313033343839383938353138323536353137323331383636300a

case "$1" in
    time)
        zcashd_start
        case "$2" in
            sleep)
                zcash_rpc zcbenchmark sleep 10
                ;;
            parameterloading)
                zcash_rpc zcbenchmark parameterloading 10
                ;;
            createjoinsplit)
                zcash_rpc zcbenchmark createjoinsplit 10
                ;;
            verifyjoinsplit)
                zcash_rpc zcbenchmark verifyjoinsplit 1000 "$RAWTXWITHPOUR"
                ;;
            solveequihash)
                zcash_rpc zcbenchmark solveequihash 10
                ;;
            verifyequihash)
                zcash_rpc zcbenchmark verifyequihash 1000
                ;;
            *)
                zcashd_stop
                echo "Bad arguments."
                exit 1
        esac
        zcashd_stop
        ;;
    memory)
        zcashd_massif_start
        case "$2" in
            sleep)
                zcash_rpc zcbenchmark sleep 1
                ;;
            parameterloading)
                zcash_rpc zcbenchmark parameterloading 1
                ;;
            createjoinsplit)
                zcash_rpc zcbenchmark createjoinsplit 1
                ;;
            verifyjoinsplit)
                zcash_rpc zcbenchmark verifyjoinsplit 1 "$RAWTXWITHPOUR"
                ;;
            solveequihash)
                zcash_rpc zcbenchmark solveequihash 1
                ;;
            verifyequihash)
                zcash_rpc zcbenchmark verifyequihash 1
                ;;
            *)
                zcashd_massif_stop
                echo "Bad arguments."
                exit 1
        esac
        zcashd_massif_stop
        rm -f massif.out
        ;;
    *)
        echo "Bad arguments."
        exit 1
esac

# Cleanup
rm -rf "$DATADIR"
