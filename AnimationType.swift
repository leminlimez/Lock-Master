// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/**
 The type of animation to play
 */
@objc public enum AnimationType: Int {
    case shrink             // id: 0
    case expand             // id: 1
    case slideLeft          // id: 2
    case slideRight         // id: 3
    case slideUp            // id: 4
    case slideDown          // id: 5
    case tv                 // id: 6
    case offBtnFadeInto     // id: 7
    case offBtnFadeOut      // id: 8 (Unused)
    case genie              // id: 9
    case flip               // id: 10
    case spinSlower         // id: 11
    case spinFaster         // id: 12
    case tvNoFadeToWhite    // id: 13
}