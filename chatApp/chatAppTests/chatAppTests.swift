import XCTest
@testable import chatApp

class ChatAppTests: XCTestCase {

    override func setUpWithError() throws {
        try? super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try? super.tearDownWithError()
    }

    func testLoadImage() throws {

        let gcdRequest: IRequestable = GCDRequest()
        
        guard let url = URL(string: "https://cdn.pixabay.com/photo/2022/04/21/19/47/lion-7148207_150.jpg") else { return }
        
        var img: UIImage?
        
        gcdRequest.loadPic(url: url, { pic in
            img = pic
        }, { _, _ in
            
        })
        
        Thread.sleep(forTimeInterval: 3)
        
        XCTAssertNil(img)
    }
    
    func testLoadImagesList() throws {
        
        let picLoader: IPictureLoadable = PicturesLoader()
        
        var pictures: [PicResponseItem] = []
        
        picLoader.getImagesList({ pics in
            pictures = pics
        })
        
        Thread.sleep(forTimeInterval: 5)
        XCTAssertEqual(100, pictures.count)
    }
    
    func testPostLoadRefresh() throws {
        let delegateMock = RefreshableMock()
        let model = PicturesModel(delegateMock)
        
        Thread.sleep(forTimeInterval: 3)

        XCTAssertEqual(100, model.loadedPictures.count)
        XCTAssertEqual(delegateMock.invokedRefreshCount, 1)
    }

    func testPerformanceExample() throws {

        self.measure {

        }
    }

}
