# You may redistribute this program and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

include $(TOPDIR)/rules.mk

PKG_NAME:=meshbox-ui
PKG_VERSION:=0.5-SNAPSHOT

include $(INCLUDE_DIR)/package.mk

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git@gitboria.com:derp/meshbox-ui.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=master
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

define Package/meshbox-ui
  SECTION:=projectmeshnet
  CATEGORY:=Project Meshnet
  TITLE:=The files for the meshbox's UI
  DEPENDS:=+lua +libuci-lua +libubus-lua
  MAINTAINER:=thefinn93 -- #projectmeshnet on irc.efnet.org
endef


define Package/meshbox-ui/description
  The user interface for the meshbox
endef

define Build/Prepare
        mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/meshbox-ui/install
        $(CP) ./meshbox-ui/* $(1)/
endef

$(eval $(call BuildPackage,meshbox-ui))
