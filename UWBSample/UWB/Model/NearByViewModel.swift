//
//  NearByViewModel.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/26.
//

import Foundation
import NearbyInteraction
import MultipeerConnectivity
//http://desappstre.com/how-to-nearbyinteraction-framework/


class NearByViewModel : NSObject, ObservableObject {
    internal static var nearbySessionAvailable : Bool {
        return NISession.isSupported
    }
    var serviceIdentity : String
    var nearbySession : NISession?
    var sharedTokenWithPeer = false
    var peer: MCPeerID?
    
    
    var multipeerSession: MCSession?
    var multipeerAdvertiser: MCNearbyServiceAdvertiser?
    var multipeerBrowser : MCNearbyServiceBrowser?
    
    var maxPeersInSession : Int = 4
    
    var peerName : String = ""
    var isConnectionLost : Bool = true
    
    var peerToken: NIDiscoveryToken?
    

    var isDirectionAvailable : Bool = false //방향을 사용할수 있는지 여부를 나타냅니다.
    
    var directionAngle : Float?
    var serviceType : String = "dd-ar"
    
    
    @Published var objects  = [NINearbyObject]()
    
    
    override internal init() {
        
        // Avoid any simulator instances from finding any actual devices.
        #if targetEnvironment(simulator)
        self.serviceIdentity = "kr.doubled.UWBSample./simulator_ni"
        #else
        //self.serviceIdentity = "kr.doubled.UWBSample./simulator_ni"
        self.serviceIdentity = "kr.doubled.UWBSample./device_ni"
        #endif
        //self.serviceIdentity = "kr.doubled.UWBSample"
        super.init()

        self.startNearbySession()
        self.startMultipeerSession()
    }
    
    /**
        Arranca la sesión de `NearbyInteraction`.
        También se inicia la sesión de `MultipeerConectivity`
        en caso que sea la primera vez que se inica la app.
    */
    internal func startNearbySession() -> Void
    {
        // 1. Creamos la NISession.
        self.nearbySession = NISession()

        // 2. Ahora el delegado.
        // Recibimos datos sobre el estado de la sesión
        self.nearbySession?.delegate = self

        // Es una nueva sesión así que tendremos que
        // intercambiar nuestro token.
        sharedTokenWithPeer = false

        // 3. Si la variable `peer` existe es porque se ha reiniciado
        // la sesión así que tenemos qque volver a compartir el token.
        if self.peer != nil && self.multipeerSession != nil
        {
            if !self.sharedTokenWithPeer
            {
                shareTokenWithAllPeers()
            }
        }
        else
        {
            self.startMultipeerSession()
        }
    }

    /**
        Arranca la sesión de `MultipeerConnectivity`
        Lo principal son los tres objetos que se crean aquí
        * `MCSession`: La sesión de MultipeerConnectivity
        * `MCNearbyServiceAdvertiser`: Se encarga de decir a todos que
                estamos aquí.
        * `MCNearbyServiceBrowser`: Nos dice si hay otros dispositivos
                ahí fuera.
        Todos estos objetos tienen sus respectivos delegados
        **donde recibimos actualizaión del estado** de todo lo relacionado
        con `MultipeerConnectivity`
     */
    
    //[MCNearbyServiceAdvertiser] PeerConnection connectedHandler (advertiser side) - error [Unable to connect].
    //[MCNearbyServiceAdvertiser] PeerConnection connectedHandler (advertiser side) - error [Unable to connect].
    
    
    private func startMultipeerSession() -> Void
    {
        if self.multipeerSession == nil
        {
            //1. 고유한 PeerID를 만든다.
            let localPeer = MCPeerID(displayName: UIDevice.current.name)

            //2. 세션 초기화
            self.multipeerSession = MCSession(peer: localPeer,
                                              securityIdentity: nil,
                                              encryptionPreference: MCEncryptionPreference.none)
            //MCAdvertiserAssistant?
            

            //3.
            self.multipeerAdvertiser = MCNearbyServiceAdvertiser(peer: localPeer,
                                                     discoveryInfo: [ "identity" : serviceIdentity],
                                                     serviceType: serviceType)

            // 6
            self.multipeerBrowser = MCNearbyServiceBrowser(peer: localPeer,
                                                           serviceType: serviceType)

            // 7
            self.multipeerSession?.delegate = self
            self.multipeerAdvertiser?.delegate = self
            self.multipeerBrowser?.delegate = self
        }

        //self.stopMultipeerSession()

        // 8
        self.multipeerAdvertiser?.startAdvertisingPeer()
        self.multipeerBrowser?.startBrowsingForPeers()
    }
    
    func stopMultipeerSession() {
        self.multipeerAdvertiser?.stopAdvertisingPeer()
        self.multipeerBrowser?.stopBrowsingForPeers()
        
    }
    private func shareTokenWithAllPeers() -> Void
    {
        guard let token = nearbySession?.discoveryToken,
              let multipeerSession = self.multipeerSession,
              let encodedData = try?  NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
        else
        {
            fatalError("Ese token no se puede codificar. 😭")
        }

        do
        {
            try self.multipeerSession?.send(encodedData,
                                            toPeers: multipeerSession.connectedPeers,
                                            with: .reliable)
        }
        catch let error
        {
            print("No se puede enviar el token a los dispositivos. \(error.localizedDescription)")
        }

        // Ya hemos compartido el token.
        self.sharedTokenWithPeer = true
    }
}
//MARK: MCNearbyServiceAdvertiserDelegate
extension NearByViewModel : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("advertiser invitationHanlder")
        
        invitationHandler(true, self.multipeerSession)
    }
   
    
    
}

extension NearByViewModel: MCNearbyServiceBrowserDelegate
{
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    

    /// 1
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) -> Void
    {
        
        print(peerID)
        
        
        guard let info = info,
              let identity = info["identity"],
              let multipeerSession = self.multipeerSession,
              (identity == self.serviceIdentity && multipeerSession.connectedPeers.count < self.maxPeersInSession)
        else
        {
            return
        }
        
        browser.invitePeer(peerID, to: multipeerSession, withContext: nil, timeout: 5)
    }
    

}

extension NearByViewModel: MCSessionDelegate
{
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
        
    /// 2
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {
        print("\(peerID.displayName) changed state: \(state)")
        
        DispatchQueue.main.async
        {
            switch state
            {
                case .connected:
                    self.peerName = peerID.displayName
                    self.peer = peerID
                    
                    // 3
                    self.shareTokenWithAllPeers()
                    
                    self.isConnectionLost = false
                    
                case .notConnected:
                    self.isConnectionLost = true
                    
                case .connecting:
                    self.peerName = "Hola ¿Quién eres? 👋"
                    
                @unknown default:
                    fatalError("Ha aparecido un estado nuevo de la enumeración. Ni idea lo que hacer.")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    {
        guard peerID.displayName == self.peerName else
        {
            // Llegan datos de un cliente que no es
            // con el que hemos iniciado la sesión
            return
        }
        
        guard let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else
        {
            fatalError("No se ha podido leer el token del otro dispositivo")
        }
        
        // Creamos la configuración...
        let config = NINearbyPeerConfiguration(peerToken: discoveryToken)

        // ...arrancamos la sesión de NearbyInteraction...
        self.nearbySession?.run(config)
        // ...y guardo el token del cliente por si tengo
        // que reanudar mi sesión.
        self.peerToken = discoveryToken
        
        DispatchQueue.main.async {
            self.isConnectionLost = false
        }
    }

}

//MARK: NISessionDelegate
extension NearByViewModel: NISessionDelegate
{

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) -> Void
    {
//        guard let nearbyObject = nearbyObjects.first else
//        {
//            return
//        }
        
        objects.removeAll()
        objects = nearbyObjects
        
        Debug.log(nearbyObjects.count)
        
        
        
//        for nearbyObject in nearbyObjects {
//            nearbyObject.distance
//
//        }
        
        
//        self.distanceToPeer = nearbyObject.distance ?? 0
//
//        // x , y, z 축으로 있음
//
//        if let direction = nearbyObject.direction
//        {
//
////            self.isDirectionAvailable = true
////            self.directionAngle = direction.x > 0.0 ? 90.0 : -90.0
//
//            
//            let angle = Double(atan2(direction.x, -(direction.y) )) * 180.0 / M_PI
//
//            //0 이 6시방향
//
//            if angle > 0 {
//                //오른쪽
//            }else {
//                //왼쪽
//            }
//            Debug.log(angle)
//            Debug.log(direction.z)
//        }
//        else
//        {
////            self.isDirectionAvailable = false
//        }
    }
    /// La sesión no vale.
      /// Hay que iniciar otra.
      func session(_ session: NISession, didInvalidateWith error: Error) -> Void
      {
          self.startNearbySession()
      }
      
      /// Se ha perdido la conexión con el otro dispositivo
      /// La sesión no vale, tenemos que crear otra.
      func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) -> Void
      {
          session.invalidate()
          self.startNearbySession()

      }
      
      /// La app vuelve al primer plano
      func sessionSuspensionEnded(_ session: NISession) -> Void
      {
          guard let peerToken = self.peerToken else
          {
              return
          }
          
          // Creamos la configuración...
          let config = NINearbyPeerConfiguration(peerToken: peerToken)
          // volvemos a levantar la sesión
          self.nearbySession?.run(config)
          
          self.shareTokenWithAllPeers()
      }
      
      /// La app pasa a background
      func sessionWasSuspended(_ session: NISession) -> Void
      {
          print("\(#function). Volveré... 🙋‍♂️")
      }

}
